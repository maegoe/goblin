---
name: goblin-roblox-qa
description: "Worker procedure for Goblin Roblox QA when routed by goblin-dev-orchestrator. Use for build checks, Roblox Studio MCP verification, console/runtime inspection, regression review, QA rerun, asset hash/dimension/alpha validation, Tarmac/Assets.lua verification, and review-driven validation. For full Jira-to-delivery workflows, route through goblin-dev-orchestrator."
---

# Goblin Roblox QA

## Purpose

Verify scoped Goblin changes against ticket acceptance criteria, Confluence completion criteria, and Roblox integration contracts.

## Inputs

- Jira key and Confluence scope.
- Implementation artifact and changed files.
- Build output or previous QA artifact.
- User-provided Studio logs or reproduction steps when available.
- Accepted final asset paths, production asset paths, or Tarmac manifest/codegen outputs when visual assets are in scope.

## Workflow

1. Read the scope, implementation summary, and changed files.
2. Check code integration across shared definitions, server services, client controllers, and Rojo mapping.
3. For production-bound assets, verify integration contracts before visual opinion:
   - production files match accepted final artifacts by SHA-256
   - exact requested dimensions
   - expected alpha/RGBA behavior for transparent assets
   - no embedded text/digits when the asset contract forbids them
   - `tarmac-manifest.toml` entries and generated `src/shared/Assets.lua` ids match
   - `tarmac sync --target none tarmac.toml` passes when Tarmac is available
4. Run `rojo build default.project.json -o build/game.rbxl` when tools are installed and build validation is relevant.
5. Prefer Roblox Studio MCP for Play start/stop, console output, and runtime state inspection when possible.
6. If Studio MCP is unavailable, mark Studio verification as pending rather than pretending it passed.
7. Classify findings as `PASS`, `FIX`, or `BLOCKED`.
8. If verdict is `FIX`, state the exact rerun boundary and the artifact evidence that must be replaced or rechecked. Delivery must depend on a rerun QA artifact, not this FIX artifact.
9. Write a QA artifact under `_workspace/goblin-dev/`.

## Output Format

Write `_workspace/goblin-dev/{task_id}_qa.md`:

- Verdict: PASS | FIX | BLOCKED
- Scope:
- Evidence:
- Commands:
- Studio Checks:
- Asset Checks:
- Findings:
- Required Fixes:
- Rerun Boundary:
- Manual Verification Still Needed:

## Validation

- Findings cite file paths, runtime observations, or command output.
- QA does not require features outside the current ticket.
- Bugs that block current acceptance criteria are explicit.
- Follow-up ideas outside scope are separated from blocking defects.
- Asset QA treats hash mismatch between production and accepted final as `FIX`, even if dimensions and visual contact sheets look acceptable.
