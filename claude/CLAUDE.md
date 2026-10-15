# Global Claude Code Instructions

## Behaviour
- Read existing code before making changes — never invent patterns
- Keep changes minimal and scoped to what was asked
- Match the existing style of the repo even if it differs from my preference
- Do not add features, refactors, comments, or tests beyond what was asked
- If unsure about scope, ask before doing more
- Fix root causes, not symptoms — never suppress errors to make them disappear
- Prefer non-interactive commands (add flags to avoid prompts)

## Code style
- Write pure functions where possible — avoid side effects on inputs or global state
- Use strict typing — avoid `any`, `unknown`, untyped variables
- All imports at the top of the file
- No default parameter values — make all parameters explicit
- No multi-mode functions (flag parameters that switch logic) — split into separate functions
- DRY, KISS, YAGNI — no speculative abstractions

## Error handling
- Always raise errors explicitly — never silently ignore them
- Use specific error types that clearly describe what went wrong
- No catch-all handlers that hide the root cause
- Error messages must include enough context to debug (params, response body, status codes)
- No fallbacks unless explicitly asked for

## Testing
- Respect the existing test strategy — do not add tests unless asked
- Prefer integration/e2e tests over unit tests when tests are needed
- Avoid mocks when real calls are practical
- Never add tests just to increase coverage numbers

## Terminal / shell
- Always use non-interactive git diff: `git --no-pager diff` or `git diff | cat`
- Prefer `rg` over `grep` for code search
- Use non-interactive flags on all shell commands

## Workflow
- Explore and understand before implementing
- Run lint/type-check after code changes if the project has them configured
- Commit with descriptive messages focused on "why", not "what"
- Keep PRs focused — one concern per PR

## DevOps context
- I work with: Kubernetes, Terraform, AWS CLI, Azure CLI, OpenShift (oc), GitLab CI, Helm
- Always be explicit about which k8s context/namespace is targeted
- Terraform: prefer `plan` before `apply`, never skip state considerations
- Treat production contexts as dangerous — confirm before any destructive action
