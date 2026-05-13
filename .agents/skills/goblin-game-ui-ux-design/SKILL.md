---
name: goblin-game-ui-ux-design
description: "Worker procedure for Goblin game UI/UX design, review, persona-agent-team-designer brief/spec routing, and imagegen-backed raster mockup generation when routed by goblin-dev-orchestrator. Use for HUD, level-up choices, combat feedback, buttons, panels, PC/mobile readability, interaction states, design discovery, design brief/spec handoff, UI mockup images, concept images, UI QA reruns, and review-driven UX fixes. For full Jira-to-delivery workflows, route through goblin-dev-orchestrator."
---

# Goblin Game UI/UX Design

## Purpose

Provide implementation-ready UI/UX guidance and generate raster mockups or concept images for scoped Goblin Roblox tasks.

## Inputs

- Jira key and Confluence scope.
- Existing UI code, screenshots, or Studio observations.
- Design asset constraints when already supplied.
- Existing or requested `design-brief.md` / design spec artifact path when discovery or production is needed.
- Requested visual target, mockup type, or image handoff path.
- Implementation artifact for review-driven fixes.

## Workflow

1. Identify the player-facing moment: HUD scan, level-up choice, combat feedback, menu/panel, or control state.
2. Confirm the requested UI work is in the current ticket scope.
3. Review existing `src/client` UI patterns before recommending changes.
4. When the request needs design discovery, a locked brief, a design spec, or multi-output design artifact planning, load `persona-agent-team-designer` and follow its routing decision tree.
5. Treat `persona-agent-team-designer` as the brief/spec process owner, not as the Goblin scope owner. Keep Jira, Confluence roadmap scope, UI design deliverable guide rules, Roblox constraints, and implementation handoff decisions in this worker's output.
6. If a `design-brief.md` or spec artifact is produced or reused, cite its path and summarize only the Goblin-relevant decisions.
7. Define practical Roblox UI behavior: hierarchy, sizing, constraints, text handling, states, and PC/mobile checks.
8. When a bitmap mockup, concept, card/button treatment, HUD preview, combat-feedback concept, or transparent cutout would materially help, load `imagegen` and generate or edit the image through that skill.
9. Save generated visual artifacts under `_workspace/goblin-dev/{task_id}_images/` or the orchestrator-provided artifact path when they are meant for project handoff.
10. Treat generated images as concept/mockup artifacts unless the ticket explicitly requests repository-managed assets.
11. Flag missing production art as a design request need; do not invent final assets or add them to the Git repo by default.
12. Separate blocking UX issues from future polish.
13. Write a UI/UX artifact under `_workspace/goblin-dev/`.

## Imagegen Rules

- Use the built-in `image_gen` path by default through the `imagegen` skill.
- For transparent-output concepts, follow the `imagegen` chroma-key removal workflow unless the user explicitly approves the CLI fallback.
- Do not overwrite existing visual artifacts without explicit approval.
- Include the final prompt, generation mode, saved image path, and whether the image is concept-only or production-bound.

## Output Format

Write `_workspace/goblin-dev/{task_id}_ui-ux-design.md`:

- UI Goal:
- Design Persona Route:
- Design Brief/Spec Artifacts:
- Player Flow:
- Layout Guidance:
- Interaction States:
- Generated Images:
- Implementation Notes:
- QA Checks:
- Scope Boundaries:
- Follow-up:

## Validation

- Text fits and does not overlap on PC/mobile target layouts.
- Tap/click targets are practical for Roblox mobile and desktop.
- State changes are visible without relying only on color.
- Recommendations map to existing code or explicitly scoped new work.
- Generated images have saved paths and are labeled concept-only or production-bound.
