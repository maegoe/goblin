# Changelog

## 2026-05-14

### Added

- KAN-51: Added persistent-upgrade-total based goblin appearance stages, MetaProgression appearance payloads, camp growth-stage badge display, and client-side character color fallback.
- KAN-51: Moved the combat growth-stage badge from overhead Billboard fallback to a fixed HUD image so it remains visible with the top-down camera.
- KAN-50: Added asset-backed camp hub UI, StartRun flow, camp level purchase validation, and integrated persistent upgrade purchase controls for KAN-49 QA.
- KAN-49: Added persistent MaxHealth/AttackDamage upgrade definitions, server-side purchase validation, GrowthStones spending, MetaProgression level updates, and PlayerState initial stat bonuses.
- KAN-48: Added defeat-based `RunResult` creation, reward calculation, automatic GrowthStones/CampMaterials payout through MetaProgression, and `RunEnded` result UI.
- KAN-47: Added the V0.4 `MetaProgression` storage foundation with default snapshot fields for growth stones, camp materials, persistent upgrades, camp level, owned artifacts, and equipped artifact id.
- KAN-47: Added server-owned DataStore loading/saving with memory fallback and `MetaProgressionChanged` server-to-client snapshot synchronization.
- KAN-47: Added a lightweight client controller that only receives server snapshots for future camp/result UI display.
- KAN-47: Changed the known Studio API Services disabled path from a warning-style load failure to a one-time informational memory fallback message.

### Validation

- `rojo build default.project.json -o build\game.rbxl` passed.
- `git diff --check` passed.
- KAN-48 Studio QA passed: result UI shows survival/kills/level/rewards, combat stops after HP reaches 0, and server logs `RunResult` with expected reward values.
- Roblox Studio QA passed: API Services disabled path uses memory fallback without the previous warning, API Services enabled path starts without MetaProgression warnings/errors, and no client write RemoteEvent exists for direct progression mutation.

## 2026-05-13

### Changed

- KAN-17: Revised the camp hub background redesign brief for a safe dark forest camp read, explicit central UI safe-area bounds, PNG-only handoff constraints, SVG-to-PNG production guardrails, and later overlay QA requirements.
- KAN-17: Added the camp hub background `Design.md` production spec artifact with canvas contract, safe-area overlay rules, composition map, palette tokens, forbidden elements, and SVG-to-PNG handoff QA notes.
- KAN-17: Replaced local `assets/v0_4/camp_ui/camp_hub_background_default_960x720.png` with a redesigned dark forest camp hub PNG generated from the approved Design.md direction, then synced the changed image through Tarmac while retaining `rbxassetid://83096712472280`.
- KAN-17: Recorded Jira completion after Confluence/Jira handoff notes and Tarmac validation were updated; KAN-16 PC/mobile overlay QA remains tracked separately.
- KAN-18~KAN-46: Delivered the V0.4 camp UI imagegen/chroma-key redesign for panels, buttons, cards, slots, icons, and badges as transparent RGBA PNGs under `assets/v0_4/camp_ui/`; earlier procedural-art outputs were rejected and not delivered.
- KAN-18~KAN-46: Updated `tarmac-manifest.toml` and generated `src/shared/Assets.lua` with Roblox asset IDs for the accepted chroma-key PNGs after Tarmac sync.
- Goblin Codex harness: Wired `persona-agent-team-planner` into scoped planning, `persona-agent-team-designer` into UI/UX brief/spec routing, and `recipe-agent-team-compound-learning` into completed-run learning capture.
- Added a Goblin Dev harness pointer to `AGENTS.md` so the orchestrator, specialist agents, runtime state rules, artifact paths, and change history are discoverable from the project root instructions.

### Validation

- KAN-17 brief QA: PASS in `_workspace/run_kan17_redesign_brief/task_kan17_brief_qa.md`; no PNG, code, Roblox asset id, or Jira status change was made.
- KAN-17 Design.md QA: PASS in `_workspace/run_kan17_design_md/task_kan17_design_md_qa.md`; no PNG, SVG, code, Roblox asset id, or Jira status change was made.
- KAN-17 image production QA: PASS in `_workspace/run_kan17_image_production/task_kan17_image_production.md`; applied PNG is 960x720 RGB with no alpha.
- KAN-17 Tarmac sync QA: PASS in `_workspace/run_kan17_image_production/task_kan17_tarmac_sync.md`; manifest hash updated and `tarmac sync --target none tarmac.toml` passes after upload. KAN-16 PC/mobile overlay QA remains pending.
- KAN-18~KAN-46 chroma-key QA rerun: PASS in `_workspace/run_kan18_46_redesign_impl/qa-chromakey/task_kan18_46_integration_qa_chromakey_rerun.md`; all 29 scoped production PNGs hash-match their imagegen/chroma-key finals, are 8-bit RGBA with alpha min/max `0/255`, have manifest and `Assets.lua` entries, and passed `tarmac sync --target none tarmac.toml` plus `rojo build default.project.json -o build/game.rbxl`. Roblox Studio MCP runtime inspection was unavailable, so in-Studio rendered UI verification remains a follow-up for KAN-16 overlay QA.
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
