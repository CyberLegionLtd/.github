# Organisation defaults

Community-health defaults include SECURITY.md, CODE_OF_CONDUCT.md and PULL_REQUEST_TEMPLATE.md. Repository-local templates take precedence.

The CLP Gates starter in workflow-templates/ appears under Actions → New workflow. Its reusable workflow and gates-ref are pinned to the same commit. Callers need an explicit private-source read credential and a repository gate profile; installing this starter does not migrate existing checks or branch protection.

Existing assurance callers must preserve governance-qg and functional-certification enforcement, their native certification command, and required status coverage during migration. Product-specific checks and privileged deployment, signing and publication remain with their owning repository.
