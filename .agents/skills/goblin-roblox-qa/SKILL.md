---
name: goblin-roblox-qa
description: "Worker procedure for Goblin Roblox QA when routed by goblin-dev-orchestrator. Use for build checks, Roblox Studio MCP verification, console/runtime inspection, regression review, QA rerun, and review-driven validation. For full Jira-to-delivery workflows, route through goblin-dev-orchestrator."
---

# Goblin Roblox QA

## Purpose

Verify scoped Goblin changes against ticket acceptance criteria, Confluence completion criteria, and Roblox integration contracts.

## Inputs

- Jira key and Confluence scope.
- Implementation artifact and changed files.
- Build output or previous QA artifact.
- User-provided Studio logs or reproduction steps when available.

## Workflow

1. Read the scope, implementation summary, and changed files.
2. Check code integration across shared definitions, server services, client controllers, and Rojo mapping.
3. Run `rojo build default.project.json -o build/game.rbxl` when tools are installed and build validation is relevant.
4. Prefer Roblox Studio MCP for Play start/stop, console output, and runtime state inspection when possible.
5. If Studio MCP is unavailable, mark Studio verification as pending rather than pretending it passed.
6. Classify findings as `PASS`, `FIX`, or `BLOCKED`.
7. Write a QA artifact under `_workspace/goblin-dev/`.

## Output Format

Write `_workspace/goblin-dev/{task_id}_qa.md`:

- Verdict: PASS | FIX | BLOCKED
- Scope:
- Evidence:
- Commands:
- Studio Checks:
- Findings:
- Required Fixes:
- Manual Verification Still Needed:

## Validation

- Findings cite file paths, runtime observations, or command output.
- QA does not require features outside the current ticket.
- Bugs that block current acceptance criteria are explicit.
- Follow-up ideas outside scope are separated from blocking defects.
