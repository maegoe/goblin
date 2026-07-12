---
name: goblin-docs-web-research
description: "Worker procedure for source-backed docs and web research when routed by goblin-dev-orchestrator. Use for Roblox API documentation, Rojo/Rokit/Luau references, platform behavior checks, stale-source review, research reruns, and source-backed implementation recommendations. For full Jira-to-delivery workflows, route through goblin-dev-orchestrator."
---

# Goblin Docs Web Research

## Purpose

Answer narrow technical questions with current, source-backed evidence for Goblin code-development tasks.

## Inputs

- Jira key and scoped research question.
- Existing Confluence or repository references.
- Affected files or APIs.
- Prior research artifact for follow-up checks.

## Workflow

1. Restate the research question and why it matters to the code task.
2. Check local repository and provided Confluence context first.
3. Use current external sources only when the answer depends on platform docs, tool behavior, or stale/unknown APIs.
4. Prefer official Roblox Creator docs, Luau docs, Rojo/Rokit docs, and official repositories.
5. Cite source titles and URLs.
6. Convert facts into implementation constraints without expanding product scope.
7. Write a research artifact under `_workspace/goblin-dev/`.

## Output Format

Write `_workspace/goblin-dev/{task_id}_docs-web-research.md`:

- Research Question:
- Sources:
- Confirmed Facts:
- Recommendation:
- Scope Impact:
- Risks:
- Follow-up:

## Validation

- Every non-obvious external fact has a source.
- Recommendations are tied to the scoped ticket.
- Speculative ideas are labeled as future/polish, not current requirements.
