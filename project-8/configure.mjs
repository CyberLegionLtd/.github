#!/usr/bin/env node
// Configures org Project #8 as the single board for every spoke and its repos.
//   PROJECT_TOKEN=<classic PAT: project, repo, read:org> node project-8/configure.mjs [--dry-run]
// Idempotent: creates missing fields/options, links every repo, adds open issues + PRs,
// and sets Spoke / Repo Type on each item (Repository is a built-in field).
const ORG = process.env.ORG ?? 'CyberLegionLtd';
const NUMBER = Number(process.env.PROJECT_NUMBER ?? 8);
const TOKEN = process.env.PROJECT_TOKEN ?? process.env.GH_TOKEN;
const DRY = process.argv.includes('--dry-run');

// Spokes from CyberLegionLtd/spokes spokes.json, plus the platform and shared layers.
const SPOKES = ['a8i', 'chyper', 'cyberlegion', 'dgidgi', 'stelargate', 'one', 'clq', 'clp', 'estate'];
const TYPES = ['hub', 'api', 'console', 'docs', 'landing', 'status', 'support', 'marketplace',
  'shop', 'registry', 'platform-service', 'capability', 'org'];
const SURFACE = new Set(TYPES.slice(1, 9));

export function classify(name) {
  if (['spokes', 'spokes-registry', 'base-registry', 'hub', '.github'].includes(name))
    return { spoke: 'estate', type: name === '.github' ? 'org' : name === 'hub' ? 'hub' : name.endsWith('registry') ? 'registry' : 'hub' };
  const [head, ...rest] = name.split('-');
  const spoke = SPOKES.includes(head) ? head : 'estate';
  const tail = rest.join('-');
  if (!tail) return { spoke, type: 'hub' };
  if (spoke === 'clp') return { spoke, type: tail === 'registry' ? 'registry' : 'platform-service' };
  if (tail.endsWith('registry')) return { spoke, type: 'registry' };
  const t = tail === 'shopping' ? 'shop' : tail;
  return { spoke, type: SURFACE.has(t) ? t : 'capability' };
}

async function gql(query, variables = {}) {
  const res = await fetch('https://api.github.com/graphql', {
    method: 'POST',
    headers: { Authorization: `bearer ${TOKEN}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ query, variables }),
  });
  const json = await res.json();
  if (json.errors) throw new Error(JSON.stringify(json.errors));
  return json.data;
}
async function mutate(query, variables) { return DRY ? null : gql(query, variables); }

async function paginate(query, vars, pick) {
  const out = []; let after = null;
  do {
    const conn = pick(await gql(query, { ...vars, after }));
    out.push(...conn.nodes);
    after = conn.pageInfo.hasNextPage ? conn.pageInfo.endCursor : null;
  } while (after);
  return out;
}

const FIELDS_Q = `query($org:String!,$n:Int!){organization(login:$org){projectV2(number:$n){id title
  fields(first:50){nodes{... on ProjectV2FieldCommon{id name dataType}
  ... on ProjectV2SingleSelectField{options{id name}}}}}}}`;

async function loadProject() {
  const p = (await gql(FIELDS_Q, { org: ORG, n: NUMBER })).organization.projectV2;
  if (!p) throw new Error(`Project #${NUMBER} not found or token lacks access`);
  return p;
}

async function ensureSelect(project, name, options) {
  const existing = project.fields.nodes.find((f) => f.name === name);
  const colors = ['BLUE', 'GREEN', 'PURPLE', 'ORANGE', 'RED', 'PINK', 'YELLOW', 'GRAY'];
  const opts = (names) => names.map((n, i) => ({ name: n, color: colors[i % colors.length], description: '' }));
  if (!existing) {
    console.log(`+ field ${name}`);
    await mutate(`mutation($p:ID!,$name:String!,$o:[ProjectV2SingleSelectFieldOptionInput!]!){
      createProjectV2Field(input:{projectId:$p,dataType:SINGLE_SELECT,name:$name,singleSelectOptions:$o}){clientMutationId}}`,
    { p: project.id, name, o: opts(options) });
    return;
  }
  const have = existing.options.map((o) => o.name);
  const missing = options.filter((o) => !have.includes(o));
  if (!missing.length) return;
  // Updating replaces the option list; keep existing option ids so item values survive.
  console.log(`~ field ${name}: add ${missing.join(', ')}`);
  await mutate(`mutation($f:ID!,$o:[ProjectV2SingleSelectFieldOptionInput!]!){
    updateProjectV2Field(input:{fieldId:$f,singleSelectOptions:$o}){clientMutationId}}`,
  { f: existing.id, o: [...existing.options.map((o) => ({ id: o.id, name: o.name, color: 'GRAY', description: '' })), ...opts(missing)] });
}

const REPOS_Q = `query($org:String!,$after:String){organization(login:$org){repositories(first:100,after:$after,isArchived:false){
  pageInfo{hasNextPage endCursor} nodes{id name}}}}`;
const WORK_Q = `query($owner:String!,$name:String!,$after:String){repository(owner:$owner,name:$name){
  issues(first:100,after:$after,states:OPEN){pageInfo{hasNextPage endCursor} nodes{id}}}}`;
const PRS_Q = `query($owner:String!,$name:String!,$after:String){repository(owner:$owner,name:$name){
  pullRequests(first:100,after:$after,states:OPEN){pageInfo{hasNextPage endCursor} nodes{id}}}}`;

async function main() {
  if (!TOKEN) throw new Error('Set PROJECT_TOKEN (classic PAT with project, repo, read:org)');
  let project = await loadProject();
  console.log(`Project #${NUMBER}: ${project.title}${DRY ? ' (dry run)' : ''}`);
  await ensureSelect(project, 'Spoke', SPOKES);
  await ensureSelect(project, 'Repo Type', TYPES);
  if (!DRY) project = await loadProject();
  const field = (n) => project.fields.nodes.find((f) => f.name === n);
  const opt = (f, n) => f?.options?.find((o) => o.name === n)?.id;

  const repos = await paginate(REPOS_Q, { org: ORG }, (d) => d.organization.repositories);
  const summary = {};
  for (const repo of repos) {
    const { spoke, type } = classify(repo.name);
    (summary[spoke] ??= []).push(`${repo.name} [${type}]`);
    await mutate(`mutation($p:ID!,$r:ID!){linkProjectV2ToRepository(input:{projectId:$p,repositoryId:$r}){clientMutationId}}`,
      { p: project.id, r: repo.id }).catch((e) => console.warn(`link ${repo.name}: ${e.message}`));

    const content = [
      ...(await paginate(WORK_Q, { owner: ORG, name: repo.name }, (d) => d.repository.issues)),
      ...(await paginate(PRS_Q, { owner: ORG, name: repo.name }, (d) => d.repository.pullRequests)),
    ];
    for (const { id } of content) {
      const added = await mutate(`mutation($p:ID!,$c:ID!){addProjectV2ItemById(input:{projectId:$p,contentId:$c}){item{id}}}`,
        { p: project.id, c: id });
      const item = added?.addProjectV2ItemById.item.id;
      if (!item) continue;
      const set = (f, value) => f && mutate(`mutation($p:ID!,$i:ID!,$f:ID!,$v:ProjectV2FieldValue!){
        updateProjectV2ItemFieldValue(input:{projectId:$p,itemId:$i,fieldId:$f,value:$v}){clientMutationId}}`,
      { p: project.id, i: item, f: f.id, v: value });
      await set(field('Spoke'), { singleSelectOptionId: opt(field('Spoke'), spoke) });
      await set(field('Repo Type'), { singleSelectOptionId: opt(field('Repo Type'), type) });
    }
    console.log(`${repo.name}: ${spoke}/${type}, ${content.length} open items`);
  }
  console.log('\nRepos per spoke:');
  for (const [s, list] of Object.entries(summary)) console.log(`  ${s} (${list.length})`);
}

if (import.meta.url === `file://${process.argv[1]}`) main().catch((e) => { console.error(e); process.exit(1); });
