# AGENTS.md

## Project Context

Before starting implementation or documentation work, read the Atlassian Confluence content in the `maegoe` workspace, `roblox` space, especially the Goblin project pages relevant to the current task.

Use the roadmap and version-specific pages as the source of truth for scope. For V0.2 work, read `V0.2 - 플레이어블 코어` and its linked feature documents before changing code or documents.

Use Jira for execution tracking. Before starting scoped implementation, QA, documentation, or planning work, find or create the relevant Jira issue in the `goblin` project (`KAN`) and link it to the corresponding Confluence roadmap, version, or feature page.

Confluence remains the source of truth for roadmap scope, feature specs, and completion criteria. Jira issues track execution state, ownership, QA, bugs, and follow-up work; they must not expand scope beyond the roadmap or version-specific Confluence pages.

Before starting worker execution for a scoped Jira issue or issue batch, move every non-complete scoped issue to `진행 중`. After delivery, move only issues with PASS QA evidence and completed Confluence/CHANGELOG records to `완료`; record any Jira transition timeout or unverified status explicitly.

## Scope Discipline

Avoid adding product design beyond the roadmap version plan. If an idea is outside the current version scope, record it as a future-version candidate instead of implementing it or expanding the current spec.

Do not broaden the current version with new systems, test harnesses, automation, balancing features, or product mechanics unless the roadmap or the user explicitly asks for that work in the current version.

If a Jira issue suggests work outside the current Confluence roadmap scope, do not implement it directly. Update or create a future-version candidate in Confluence first, then adjust Jira only after the scope is accepted.

## Design Requests

For UI art, icon, HUD, card, button, panel, or other design asset work, use the Confluence `UI 디자인 산출물 가이드` as the source of truth before creating Jira tickets.

Create Jira design request tickets from that guide instead of inventing ad hoc asset requirements. Each design Jira ticket should include the related Confluence link, target version, screen/component, purpose, requested filename, recommended size, extension, transparency requirement, 9-slice requirement, required states, priority, design token needs, and Roblox asset id handoff expectations.

Do not add design files, original assets, or PNGs to the Git repo unless the roadmap, design guide, or user explicitly asks for repository-managed assets. Track design originals, PNG delivery, Roblox asset ids, applied code/commit, and verification status in Confluence and Jira.

When a delivered design asset is applied in code, update the Jira ticket and the Confluence delivery table with the Roblox asset id, applied code or commit, PC/mobile verification result, and any follow-up issues.

For imagegen-backed production asset work, require `design-brief.md`, `Design.md`, `token-catalog.md`, and an asset matrix before production unless the orchestrator intentionally scopes a single already-specified asset. Final visual artwork must come from `imagegen`; procedural drawing via Python, JS, SVG, canvas, PIL, ImageMagick, or hand-coded rendering is not accepted as final artwork. Mechanical post-processing may only copy/move, resize/crop, validate, or apply imagegen-skill chroma-key alpha conversion.

## QA Testing

Use Roblox Studio MCP for QA testing when possible. Prefer opening the built place in Roblox Studio, starting/stopping Play, reading console output, and inspecting runtime state through the MCP tools before asking for manual verification.

Keep QA focused on the current roadmap version's completion criteria. Do not add new test harnesses or automation code unless that work is explicitly in scope for the current version.

Record QA results on the relevant Jira issue as well as in Confluence. Bugs found during QA should be created or linked in Jira and classified against the Confluence bug severity and scope rules before implementation.

## Git Branch Strategy

Use `main` as the stable release and deployment branch. Do not commit directly to `main` unless the user explicitly requests it or an emergency hotfix process requires it.

Use `dev` as the active integration branch for the current roadmap version. Start normal implementation, QA support, and documentation branches from an up-to-date `dev`.

Create a short-lived working branch for each scoped task and include the Jira key in the branch name. Use these prefixes:

- `feat/KAN-123-short-name` for feature implementation
- `fix/KAN-123-short-name` for bug fixes
- `docs/KAN-123-short-name` for documentation-only changes
- `qa/KAN-123-short-name` for QA instrumentation or verification support
- `hotfix/KAN-123-short-name` for urgent fixes branched from `main`

Before switching branches, merging, rebasing, or pulling, check the worktree status and do not overwrite user changes. If unrelated dirty files exist, leave them alone and continue only when the requested work can be isolated safely.

Merge working branches back to `dev` after the relevant code, QA notes, Confluence updates, CHANGELOG entry, and Jira updates are complete. Merge `dev` to `main` only at release or deployment checkpoints that are reflected in Confluence and Jira.

For hotfixes, branch from `main`, keep the fix narrowly scoped, update Confluence/Jira/CHANGELOG, merge to `main`, then bring the same fix back into `dev` so the active development branch does not regress.

Do not force-push, rewrite shared history, delete remote branches, or rebase branches other people may be using unless the user explicitly asks for that operation.

## Work Logging

After completing any implementation, QA, documentation, or planning work, always update Confluence before considering the task done.

Record the work in `CHANGELOG`, and also update the relevant roadmap version page or version-specific work page with the result, status, and checklist changes. If the work changes scope, implementation status, QA status, or follow-up tasks, make that explicit in the related Confluence page.

Also update the related Jira issue before considering the task done. Add the result, QA notes, Confluence links, and follow-up issues when relevant; move the issue status only when the Confluence documentation and `CHANGELOG` have already been updated.

## Harness: Goblin Dev

**Goal:** Coordinate scoped Goblin Roblox development from existing Jira tickets and Confluence source-of-truth pages through scope, implementation, QA, delivery recording, and reusable learning capture.

**Trigger:** Use `.agents/skills/goblin-dev-orchestrator/SKILL.md` for Jira-backed Goblin code work, QA, scoped docs/web research, game UI/UX design, retry/rerun/refine follow-ups, delivery recording, and completed-run learning capture. Simple local questions may be answered directly.

**Model:** Follows an orchestrator/specialist structure adapted to Codex-native skills, agents, artifacts, and Agent Team runtime.

**Orchestrator:** `.agents/skills/goblin-dev-orchestrator/SKILL.md`
**Agents:** `.codex/agents/`
**Artifacts:** `_workspace/{run_id}/` when runtime execution is active; `_workspace/goblin-dev/` for local Goblin harness artifacts and handoff notes.

**Runtime State:**

- Load `agent-team-shared` first for global runtime rules.
- Use `persona-agent-team-planner` only inside scoped Goblin planning when terminology, acceptance criteria, plan stress-testing, architecture design, or implementation task contracts need a reusable pre-execution artifact.
- Use `persona-agent-team-designer` through `goblin-game-ui-ux-designer` for scoped UI/visual design discovery, `design-brief.md` repair, design spec production, or multi-output visual planning.
- For production-bound visual assets, the orchestrator must pass an explicit imagegen production contract to workers, require production-path hash checks against accepted finals, and make delivery depend on a PASS QA or rerun QA artifact.
- Use `recipe-agent-team-compound-learning` only after completed non-trivial work, QA, review, or bug-fix evidence exists; prefer run-scoped `_workspace/{run_id}/compound-learning.md` and do not use local solution docs to replace Confluence roadmap or feature scope.
- Use `recipe-agent-team-run-lifecycle` for full runs, `recipe-agent-team-worker-checkpoint` for worker checkpoints, and `recipe-agent-team-operational-audit` for audit/status/cleanup.
- Use service skills for navigation: `agent-team-run`, `agent-team-task`, `agent-team-inbox`, `agent-team-sync`, and `agent-team-ops`.
- Use exact command helper skills for command syntax and flags, for example `agent-team-task-complete`, `agent-team-sync-check`, `agent-team-message-send`, or `agent-team-event-log`.
- `RUN_ID` and `TASK_ID` are orchestrator-owned internal context, not required user input.
- If the user provides an advanced/debug `RUN_ID` or `TASK_ID`, inspect and resume that run/task before creating new state.
- Do not use runtime state during harness setup, editing, audit-only work, simple one-shot answers, or explicitly local-only runs.
- Orchestrator owns run creation, task creation, evidence aggregation, inbox/sync checks, and artifact integration.
- Workers update only their assigned task.
- Completed tasks require evidence and an artifact path.
- Blocked tasks require a concrete blocked reason.
- `_workspace/` is for artifacts and reports only.

**Change History:**

| Date       | Change                                                         | Target                                                              | Reason                                                                                                                                                      |
| ---------- | -------------------------------------------------------------- | ------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-05-13 | Document Goblin Dev harness pointer                            | `.agents/skills/goblin-dev-orchestrator/SKILL.md`, `.codex/agents/` | Make local specialist harness discoverable from root instructions.                                                                                          |
| 2026-05-13 | Wire planner, designer, and compound-learning personas/recipes | Goblin Dev harness                                                  | Support scoped pre-execution planning, UI design brief/spec routing, and completed-run learning capture.                                                    |
| 2026-05-13 | Apply KAN-17~46 run feedback                                   | Goblin Dev harness                                                  | Enforce Jira `진행 중` start state, imagegen-only production asset contracts, asset hash QA, rerun-QA delivery gating, and multi-ticket transition ledgers. |
