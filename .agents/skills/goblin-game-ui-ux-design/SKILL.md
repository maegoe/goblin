---
name: goblin-game-ui-ux-design
description: "Worker procedure for Goblin game UI/UX design, review, persona-agent-team-designer brief/spec/token-catalog routing, and imagegen-backed raster mockup or production-asset generation when routed by goblin-dev-orchestrator. Use for HUD, level-up choices, combat feedback, buttons, panels, cards, badges, PC/mobile readability, interaction states, design discovery, design brief/spec handoff, token catalogs, asset matrices, UI mockup images, concept images, imagegen/chroma-key asset production, UI QA reruns, and review-driven UX fixes. For full Jira-to-delivery workflows, route through goblin-dev-orchestrator."
---

# Goblin Game UI/UX Design

## Purpose

Provide implementation-ready UI/UX guidance and generate raster mockups, concept images, or explicitly scoped imagegen-backed production assets for Goblin Roblox tasks.

## Inputs

- Jira key and Confluence scope.
- Existing UI code, screenshots, or Studio observations.
- Design asset constraints when already supplied.
- Existing or requested `design-brief.md` / design spec artifact path when discovery or production is needed.
- Existing or requested `Design.md`, `token-catalog.md`, or asset production matrix when design assets are in scope.
- Requested visual target, mockup type, or image handoff path.
- Implementation artifact for review-driven fixes.

## Workflow

1. Identify the player-facing moment: HUD scan, level-up choice, combat feedback, menu/panel, or control state.
2. Confirm the requested UI work is in the current ticket scope.
3. Review existing `src/client` UI patterns before recommending changes.
4. When the request needs design discovery, a locked brief, a design spec, token catalog, asset matrix, or multi-output design artifact planning, load `persona-agent-team-designer` and follow its routing decision tree.
5. Treat `persona-agent-team-designer` as the brief/spec process owner, not as the Goblin scope owner. Keep Jira, Confluence roadmap scope, UI design deliverable guide rules, Roblox constraints, and implementation handoff decisions in this worker's output.
6. If a `design-brief.md`, `Design.md`, token catalog, or asset matrix is produced or reused, cite its path and summarize only the Goblin-relevant decisions.
7. Define practical Roblox UI behavior: hierarchy, sizing, constraints, text handling, states, and PC/mobile checks.
8. When a bitmap mockup, concept, card/button treatment, HUD preview, combat-feedback concept, transparent cutout, or explicitly scoped production asset would materially help, load `imagegen` and generate or edit the image through that skill.
9. For production-bound asset work, write or reuse the design chain before image production: `design-brief.md`, `Design.md`, `token-catalog.md`, and an asset matrix. Do not start production tasks without these artifacts unless the orchestrator explicitly narrows the scope to a single already-specified asset.
10. Save generated visual artifacts under `_workspace/goblin-dev/{task_id}_images/` or the orchestrator-provided artifact path when they are meant for project handoff.
11. Treat generated images as concept/mockup artifacts unless the ticket, design guide, or user explicitly requests repository-managed production assets.
12. For production-bound assets, verify the copied production file hash matches the accepted final artifact before completing the task.
13. Flag missing production art as a design request need; do not invent final assets or add them to the Git repo by default.
14. Separate blocking UX issues from future polish.
15. Write a UI/UX artifact under `_workspace/goblin-dev/`.

## Imagegen Rules

- Use the built-in `image_gen` path by default through the `imagegen` skill.
- For transparent-output concepts, follow the `imagegen` chroma-key removal workflow unless the user explicitly approves the CLI fallback.
- If the user or orchestrator requires imagegen-backed final artwork, do not create final visual artwork with Python, JS, SVG, canvas, PIL, ImageMagick, or hand-coded procedural drawing. Those tools may not be used as a substitute for imagegen.
- Allowed mechanical post-processing for imagegen-backed final artwork is limited to copying/moving, resizing/cropping to requested dimensions, format validation, and imagegen-skill chroma-key removal to convert a flat generated background to alpha.
- Record every mechanical post-processing command in the artifact when production assets are delivered.
- Production-bound completion requires both workspace final validation and production path validation, including SHA match between accepted final and production file.
- Do not overwrite existing visual artifacts without explicit approval.
- Include the final prompt, generation mode, saved image path, and whether the image is concept-only or production-bound.

## Output Format

Write `_workspace/goblin-dev/{task_id}_ui-ux-design.md`:

- UI Goal:
- Design Persona Route:
- Design Brief/Spec Artifacts:
- Token Catalog / Asset Matrix:
- Visual Production Contract:
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
- Production-bound assets cite accepted final paths, production paths, post-processing commands, and hash-match evidence.
