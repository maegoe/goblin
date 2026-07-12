---
name: goblin-code-implementation
description: "Worker procedure for scoped Goblin Roblox/Luau implementation when routed by goblin-dev-orchestrator. Use for ticket-based code changes, bug fixes, review fixes, partial implementation reruns, and implementation summaries. For full Jira-to-delivery workflows, route through goblin-dev-orchestrator."
---

# Goblin Code Implementation

## Purpose

Implement the smallest code change that satisfies an existing Jira ticket and linked Confluence scope.

## Inputs

- Jira key and scope summary.
- Scope plan artifact.
- Files or modules assigned by the orchestrator.
- Previous QA/review findings for follow-up fixes.

## Workflow

1. Read the assigned scope and affected files before editing.
2. Confirm the change is inside the ticket and Confluence page scope.
3. Preserve unrelated dirty files and user edits.
4. Match existing module boundaries:
   - `src/server`: combat, player state, enemies, waves, experience, upgrades.
   - `src/client`: camera, HUD, level-up UI, client boot.
   - `src/shared`: definitions, config, remotes, shared constants.
5. Edit only files needed for the assigned behavior.
6. Run focused validation requested by the orchestrator.
7. Write an implementation artifact under `_workspace/goblin-dev/`.

## Output Format

Write `_workspace/goblin-dev/{task_id}_implementation.md`:

- Jira:
- Scope:
- Changed Files:
- Behavior:
- Scope Mapping:
- Validation:
- Risks:
- Follow-up:

## Validation

- Code compiles/builds where local tools are available.
- Shared/server/client contracts still line up.
- No new product scope, assets, or automation was added without explicit scope.
- Review-driven fixes cite the QA finding they address.
