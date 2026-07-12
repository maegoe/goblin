---
name: goblin-delivery-recording
description: "Worker procedure for recording completed Goblin code-development results after implementation and PASS QA when routed by goblin-dev-orchestrator, with optional recipe-agent-team-compound-learning capture for completed non-trivial work. Use for Jira comments, Confluence result updates, CHANGELOG entries, delivery handoff, rerun result updates, multi-ticket status transition recording, compound learning notes, and completion notes. Do not use for initial ticket creation, initial Confluence spec writing, active implementation, active planning/design, or delivery from a FIX QA artifact unless explicitly requested."
---

# Goblin Delivery Recording

## Purpose

After scoped code work and QA are complete, record the outcome in existing project tracking locations.

## Inputs

- Jira key supplied by the user.
- Existing Confluence page links from the scope plan.
- Implementation artifact.
- PASS QA artifact. If the latest QA verdict is `FIX`, delivery waits for a rerun QA artifact.
- Branch, commit, or diff summary when available.
- Optional completed-run evidence and reusable learning candidate.

## Workflow

1. Confirm implementation artifacts and a PASS QA artifact exist. If QA is `FIX`, block delivery or request a rerun QA dependency.
2. Prepare concise result notes:
   - changed files
   - behavior delivered
   - validation evidence
   - QA result
   - follow-up or blockers
3. Update existing Confluence targets and CHANGELOG before moving Jira status to `완료`.
4. Update existing Jira targets when connector tools are available.
5. For multi-ticket delivery, record each successful external update immediately in the artifact or a sidecar table: Jira issue key, comment id if returned, Confluence page/comment id if returned, CHANGELOG status, status transition attempted, transition result, and any unverified timeout.
6. Treat Jira comments and Jira status transitions as separate records. A successful delivery comment does not prove the workflow status changed.
7. If a status transition times out, re-read that issue once when practical. If it still cannot be verified, record it as unverified instead of assuming success.
8. If the completed work produced reusable knowledge, load `recipe-agent-team-compound-learning` after delivery recording and capture the learning with evidence.
9. Prefer run-scoped `_workspace/{run_id}/compound-learning.md`; use `_workspace/goblin-dev/{task_id}_compound-learning.md` only when no runtime run id exists.
10. Promote to `docs/solutions/` only when the user explicitly asks for durable local solution docs or the lesson is clearly reusable outside the current run and does not conflict with Confluence as product scope source of truth.
11. Do not create new Jira tickets or initial Confluence pages unless the user explicitly asks.
12. If connectors are unavailable, write exact handoff text under `_workspace/goblin-dev/`.

## Output Format

Write `_workspace/goblin-dev/{task_id}_delivery.md`:

- Jira Updated: yes | no | handoff
- Confluence Updated: yes | no | handoff
- CHANGELOG Updated: yes | no | handoff
- Jira Comment:
- Confluence Update:
- CHANGELOG Entry:
- QA Evidence:
- Status Change:
- External Update Ledger:
- Compound Learning: captured | skipped | recommended
- Compound Learning Artifact:
- Follow-up:

## Validation

- Delivery notes match the implementation and QA artifacts.
- Jira status is not moved before Confluence/CHANGELOG recording is done and PASS QA evidence exists.
- Multi-ticket delivery records completed and unverified external update results separately, including connector timeouts.
- Handoff text is ready to apply if external update tools are unavailable.
- Compound learning is captured only after completion evidence exists and is skipped for trivial, uncertain, or active work.

## Compound Learning Criteria

Capture non-obvious bugs, repeated QA or Studio workflows, reusable Rojo/Rokit/Luau/Tarmac behavior, architecture decisions, design handoff patterns, and agent coordination lessons. Skip trivial typo fixes, uncertain outcomes, active work, and one-off local changes with no likely reuse.
