# Changelog

## 2026-05-13

### Changed

- KAN-17: Revised the camp hub background redesign brief for a safe dark forest camp read, explicit central UI safe-area bounds, PNG-only handoff constraints, SVG-to-PNG production guardrails, and later overlay QA requirements.
- KAN-17: Added the camp hub background `Design.md` production spec artifact with canvas contract, safe-area overlay rules, composition map, palette tokens, forbidden elements, and SVG-to-PNG handoff QA notes.
- Goblin Codex harness: Wired `persona-agent-team-planner` into scoped planning, `persona-agent-team-designer` into UI/UX brief/spec routing, and `recipe-agent-team-compound-learning` into completed-run learning capture.
- Added a Goblin Dev harness pointer to `AGENTS.md` so the orchestrator, specialist agents, runtime state rules, artifact paths, and change history are discoverable from the project root instructions.

### Validation

- KAN-17 brief QA: PASS in `_workspace/run_kan17_redesign_brief/task_kan17_brief_qa.md`; no PNG, code, Roblox asset id, or Jira status change was made.
- KAN-17 Design.md QA: PASS in `_workspace/run_kan17_design_md/task_kan17_design_md_qa.md`; no PNG, SVG, code, Roblox asset id, or Jira status change was made.
- Static harness validation: confirmed planner/designer/compound-learning references are present in the orchestrator, specialist agent definitions, worker skills, trigger tests, and root harness pointer.

## 2026-05-12

### Added

- KAN-17~KAN-46: Added V0.4 camp UI asset handoff for 30 PNG files under `assets/v0_4/camp_ui/`, Tarmac config, generated asset manifest, and generated `src/shared/Assets.lua` references.

### Validation

- QA rerun result: PASS.
- PNG manifest verification: 30 manifest rows, 30 PNG files, 30 metadata checks, 0 failures.
- `tarmac.toml` parses with `upload-to-group-id = 738487850`.
- `tarmac sync --target none tarmac.toml` passed after the Tarmac manifest and Roblox asset ids were generated.
- `rojo build default.project.json -o build/game.rbxl` passed.
- `git diff --check` passed.

### Follow-up

- Roblox asset ids were generated in `src/shared/Assets.lua` and `tarmac-manifest.toml`; runtime UI wiring remains a follow-up.
- Studio/runtime visual placement QA remains pending because this rerun covered static asset metadata, Tarmac config parsing, deliverable file set, Rojo build, and whitespace validation only.
