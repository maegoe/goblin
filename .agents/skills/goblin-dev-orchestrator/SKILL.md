---
name: goblin-dev-orchestrator
description: "Goblin Roblox code-development orchestrator for working from an existing Jira ticket and existing Confluence scope. Use for 'implement KAN-123', ticket-based coding, bug fix, feature work, docs/web research, planning grill, architecture planning, game UI/UX design, persona-agent-team-designer brief/spec routing, imagegen-backed UI mockups, code review, QA, retry, rerun, update, refine, audit previous work, compound learning, resume a run, or record completed delivery. This harness does not create Jira tickets or initial Confluence specs unless explicitly requested; it records Jira/Confluence/CHANGELOG results after development and QA."
---

# Goblin Dev Orchestrator

## Purpose

Coordinate scoped Goblin code development from an existing Jira ticket and existing Confluence source-of-truth pages through planning, implementation, QA, and delivery recording.

This harness is for code-development execution. It must not invent roadmap scope, issue new tickets, or create initial spec documents by default.

## Inputs

- User request, ideally including a Jira key such as `KAN-7`.
- Existing Confluence roadmap/version/feature links or enough Jira context to find the linked pages.
- Current repository state.
- Optional research question for current Roblox/Rojo/Rokit/Luau docs or platform behavior.
- Optional pre-execution planning need such as terminology alignment, plan stress-testing, acceptance criteria, architecture design, or implementation task contracts.
- Optional UI/UX target such as HUD, level-up UI, combat feedback, buttons, panels, PC/mobile layout, interaction states, or generated visual mockup.
- Optional design discovery, design brief, or design spec need for scoped UI/visual work.
- Optional compound-learning request after a completed non-trivial run or fix.
- Optional previous `_workspace/goblin-dev/` artifact path for follow-up work.

If the user asks for code work without a Jira key or existing scope source, ask for the missing ticket or Confluence page before implementation unless the request is a tiny local cleanup with no product impact.

## Route

| Request | Action |
| --- | --- |
| Simple local question | Answer directly without runtime state. |
| Implement or fix from existing Jira ticket | Run the full development workflow. |
| Review or QA current branch | Use QA/reviewer phases and record findings. |
| Terminology alignment, plan stress-test, acceptance hardening, architecture design, or task-contract planning needed before code | Route to `goblin-scope-architect`; it may load `persona-agent-team-planner` while preserving Confluence/Jira scope boundaries. |
| Docs or web research needed for implementation | Route to `goblin-docs-web-searcher`; use source-backed facts only inside current scope. |
| Game UI/UX behavior, mockup, or image concept needed | Route to `goblin-game-ui-ux-designer`; it may load `persona-agent-team-designer` for brief/spec routing and `imagegen` for raster UI mockups or concept images when useful. |
| Design discovery, locked brief, design spec, or multi-output visual planning needed | Route to `goblin-game-ui-ux-designer`; it uses `persona-agent-team-designer` as the process router while preserving Goblin Jira/Confluence scope boundaries. |
| Follow-up, retry, refine, partial rerun | Read previous artifacts, preserve unaffected work, rerun only the requested phase. |
| Jira ticket creation or initial Confluence spec writing | Do not perform by default; ask for explicit confirmation or hand back required fields. |
| Delivery recording after code/QA | Update existing Jira/Confluence/CHANGELOG targets, or write a handoff artifact if tools are unavailable. |
| Reusable lessons from a completed non-trivial run, fix, review, or QA cycle | Route after delivery to `goblin-delivery-recorder`; it may load `recipe-agent-team-compound-learning` and write a run-scoped learning artifact. |

## Specialist Roster

| Agent | Role | Model | Reasoning | Sandbox | Output |
| --- | --- | --- | --- | --- | --- |
| `goblin-scope-architect` | Scope analysis, impact map, implementation plan | `gpt-5.5` | `xhigh` | `workspace-write` | `_workspace/goblin-dev/{task_id}_scope-plan.md` |
| `goblin-implementation-engineer` | Luau/Rojo implementation | `gpt-5.5` | `high` | `workspace-write` | `_workspace/goblin-dev/{task_id}_implementation.md` |
| `goblin-docs-web-searcher` | Source-backed technical docs and web research | `gpt-5.5` | `medium` | `workspace-write` | `_workspace/goblin-dev/{task_id}_docs-web-research.md` |
| `goblin-game-ui-ux-designer` | Scoped game UI/UX design plus imagegen-backed mockups/concepts | `gpt-5.5` | `high` | `workspace-write` | `_workspace/goblin-dev/{task_id}_ui-ux-design.md` |
| `goblin-qa-reviewer` | Build, integration, and Studio-oriented QA review | `gpt-5.5` | `high` | `workspace-write` | `_workspace/goblin-dev/{task_id}_qa.md` |
| `goblin-delivery-recorder` | Existing Jira/Confluence/CHANGELOG result updates | `gpt-5.5` | `high` | `workspace-write` | `_workspace/goblin-dev/{task_id}_delivery.md` |

## Execution Modes

- `direct`: Use for tightly coupled small fixes, local questions, or when delegation is not explicitly useful.
- `delegated`: Use only when the active Codex environment allows subagents and independent scope, implementation, QA, or recording tasks can run in parallel.
- `hybrid`: Default for normal ticket work. Scope planning is direct or delegated first; docs/web research and UI/UX design run only when the scoped task needs them; implementation is direct or delegated by file ownership; QA can be delegated after code changes; delivery recording runs after QA evidence exists.

Ordinary workers never spawn subagents.

## Workflow

1. Check repository status before branch or file changes. Preserve user changes and unrelated dirty files.
2. Resolve existing scope: Jira ticket, linked Confluence roadmap/version/feature pages, and acceptance criteria.
3. Confirm this is not a request to create a ticket or initial spec page. If it is, ask for explicit permission before doing so.
4. Create or verify a short-lived working branch only when safe and useful. Branch names should include the Jira key, such as `feat/KAN-123-short-name` or `fix/KAN-123-short-name`.
5. Write a scope plan artifact under `_workspace/goblin-dev/`.
6. When terms, acceptance criteria, architecture boundaries, or implementation task contracts are ambiguous, the scope specialist loads `persona-agent-team-planner` and cites any produced planning artifacts in the scope plan.
7. Route docs/web research when implementation depends on current external technical facts.
8. Route game UI/UX design when the task touches HUD, level-up UI, combat feedback, panels, controls, readability, interaction states, design discovery, design brief/spec production, or generated visual mockups.
9. For design discovery or artifact specification, the UI/UX specialist loads `persona-agent-team-designer` and cites any produced `design-brief.md` or spec artifact in the UI/UX artifact.
10. For image-backed UI/UX work, the UI/UX specialist loads `imagegen`, generates the requested raster mockup/concept, and stores it under the task artifact path unless the user requests preview-only output.
11. Implement the smallest code change that satisfies the scope.
12. Validate with focused checks. Prefer `rojo build default.project.json -o build/game.rbxl`; use Roblox Studio MCP for Play/console/runtime QA when available and relevant.
13. Run QA review against integration contracts and completion criteria.
14. Fix any scoped QA findings. Do not add new systems, balancing, assets, or automation outside the ticket.
15. Record completion after code and QA: update existing Jira, existing Confluence pages, and CHANGELOG. If connectors are unavailable, write exact handoff text in `_workspace/goblin-dev/`.
16. If the completed work produced reusable knowledge, route to `recipe-agent-team-compound-learning` through the delivery specialist and store a run-scoped learning artifact.
17. Final response includes changed files, validation evidence, generated image paths when applicable, Jira/Confluence recording status, compound-learning artifact path when applicable, and unresolved risks.

## Data Flow

| Phase | Inputs | Mode | Specialist | Artifact | Evidence | Next Consumer | Failure Path |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Scope | User request, Jira key, Confluence pages, repo files, optional planning ambiguity | direct or delegated | `goblin-scope-architect` using `persona-agent-team-planner` when terminology, planning grill, architecture design, or task-contract routing is needed | `_workspace/goblin-dev/{task_id}_scope-plan.md` plus optional planner artifact paths | linked sources, planner artifact citations, affected files | Implementation | BLOCKED if ticket/spec is missing or planner cannot resolve a required decision |
| Docs/Web Research | Scope plan, research question, current docs need | direct or delegated | `goblin-docs-web-searcher` | `_workspace/goblin-dev/{task_id}_docs-web-research.md` | cited sources, confirmed facts | Scope or Implementation | BLOCKED if source is unavailable or conflicts with scope |
| UI/UX Design | Scope plan, UI target, existing UI code/screens, image request, optional brief/spec need | direct or delegated | `goblin-game-ui-ux-designer` using `persona-agent-team-designer` when brief/spec routing is needed | `_workspace/goblin-dev/{task_id}_ui-ux-design.md` plus optional `_workspace/goblin-dev/{task_id}_images/` or design brief/spec paths | player flow, layout rules, generated image paths, brief/spec citations, QA checks | Implementation or QA | BLOCKED if required assets/spec are missing |
| Implementation | Scope plan, source files | direct or delegated | `goblin-implementation-engineer` | `_workspace/goblin-dev/{task_id}_implementation.md` | diff summary, files changed | QA | Retry with narrower file ownership |
| QA | Implementation artifact, code diff, completion criteria | direct or delegated | `goblin-qa-reviewer` | `_workspace/goblin-dev/{task_id}_qa.md` | build/Studio/static checks | Fix or delivery | FIX if scoped defect, BLOCKED if environment missing |
| Delivery | Scope, implementation, QA evidence | direct | `goblin-delivery-recorder` | `_workspace/goblin-dev/{task_id}_delivery.md` | Jira/Confluence/CHANGELOG update result | Final response | Handoff artifact if update tools unavailable |
| Compound Learning | Completed delivery artifact, QA evidence, task/run artifacts, reusable lesson candidate | direct | `goblin-delivery-recorder` using `recipe-agent-team-compound-learning` when evidence supports capture | `_workspace/{run_id}/compound-learning.md` or `_workspace/goblin-dev/{task_id}_compound-learning.md` fallback | learning track, evidence, reusable guidance, follow-ups | Future scope/planning/design/QA | SKIP if trivial, active, uncertain, or not reusable |

## Runtime Contract

- Runtime coordination is skill-first: load runtime recipe/service/helper skills, then use daemonless `agent-team` commands only through those helper contracts.
- Load `agent-team-shared` first for global runtime behavior.
- Use personas and recipes for workflow shape: `persona-agent-team-planner` for terminology alignment, planning grill, acceptance criteria, architecture design, and implementation task contracts inside scope work; `persona-agent-team-designer` for design discovery, design brief repair, and design spec production inside UI/UX work; `recipe-agent-team-compound-learning` for reusable lessons after completed non-trivial work; `recipe-agent-team-run-lifecycle` for full runs, `recipe-agent-team-worker-checkpoint` for worker checkpoints, and `recipe-agent-team-operational-audit` for audit/status/cleanup.
- For exact command behavior, load helper skills such as `agent-team-run-create`, `agent-team-task-create`, `agent-team-task-complete`, `agent-team-sync-check`, `agent-team-message-send`, and `agent-team-event-log`.
- Use service skills only for navigation: `agent-team-run`, `agent-team-task`, `agent-team-inbox`, `agent-team-sync`, and `agent-team-ops`.
- Harness setup, edit, and audit requests do not probe runtime state.
- `RUN_ID` and `TASK_ID` are orchestrator-owned internal context, not required user input.
- Resolve context in this order: active in-session context, advanced/debug user-provided IDs, recent open run plus previous artifacts, user choice among ambiguous recent runs, then a new generated-ID run.
- If no runtime context is available for an orchestrated run, load `agent-team-run-create` and `agent-team-task-create`, then create one run and task records without explicit IDs and capture the returned JSON IDs.
- Workers receive orchestrator-supplied `RUN_ID`, `TASK_ID`, `AGENT`, `ARTIFACT_ROOT`, and optional `AGENT_TEAM_STATE_DIR` only for assigned durable tasks.
- Workers update only their assigned task.
- The orchestrator creates tasks, verifies evidence, checks inbox/sync status, and integrates artifacts.
- `_workspace/goblin-dev/` stores artifacts and reports only.

## Delivery Rules

- Do not create Jira tickets unless the user explicitly asks.
- Do not create initial Confluence feature/spec pages unless the user explicitly asks.
- After implementation and QA, record results in existing Jira and Confluence targets.
- Do not move Jira status until Confluence/CHANGELOG updates are complete or the blocker is documented.
- If Jira/Confluence tools are unavailable, produce a handoff artifact containing exact text for the user to apply.

## Validation

- Scope plan cites Jira and Confluence sources or clearly marks what is missing.
- Planner artifacts are cited when used, and they harden existing scope rather than expanding roadmap scope.
- Docs/web research uses source-backed facts and does not broaden ticket scope.
- UI/UX guidance stays implementation-ready, uses `persona-agent-team-designer` for brief/spec routing when needed, uses `imagegen` for bitmap mockups/concepts when useful, and separates required fixes from future polish.
- Implementation changes map to the affected modules and no unrelated files are modified.
- QA checks build and integration contracts; Studio MCP is used when available and relevant.
- Delivery notes include changed files, QA evidence, and follow-up issues.
- Compound learning runs only after completion evidence exists and records reusable guidance without treating Confluence scope as local solution docs.
- `_workspace/` is not used as a task board.

## Follow-Up Support

For rerun, retry, update, refine, partial rerun, review, or QA follow-up:

1. Read the previous artifact if supplied or discover the latest relevant `_workspace/goblin-dev/` artifact.
2. Preserve unaffected code and notes.
3. Rerun only the requested phase unless the dependency chain requires more.
4. Cite what changed and which evidence was reused.

## Test Scenarios

Normal flow:

1. User says `KAN-123 구현해줘` with linked Confluence already present.
2. Orchestrator resolves existing scope, writes a plan, optionally routes docs/web or UI/UX specialist work, implements code, runs build/QA, updates existing Jira/Confluence/CHANGELOG, and reports evidence.

Failure flow:

1. User asks to implement `KAN-123`, but the ticket has no linked Confluence scope and the requested behavior is product-facing.
2. Orchestrator blocks before code, asks for the existing scope page or explicit permission for planning work, and does not invent requirements.

Follow-up flow:

1. User says `이전 KAN-123 QA만 다시 돌려줘`.
2. Orchestrator reads previous artifacts, runs only QA, updates the QA/delivery records, and leaves implementation unchanged.

## References

- Trigger and near-miss tests: `references/trigger-tests.md`
