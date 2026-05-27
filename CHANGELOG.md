# Changelog

## 2026-05-28

### Changed

- KAN-75: Updated Confluence after the sound deliverables guide was moved under the common `Development` page, reframing it as a project-wide sound handoff guide and linking it from the V1.0 parent page plus the KAN-66 combat feedback spec.
- KAN-75: Added the Asphalt audio asset pipeline scaffold with `asphalt.toml`, a Rokit Asphalt tool pin, `AudioAssets.luau` codegen target documentation, and local secret/debug ignore rules.
- KAN-76: Created a V1.0 sound deliverables request ticket for the seven KAN-66 combat feedback SFX files, linked it to KAN-66 and KAN-75, and recorded it on the V1.0 parent page, combat feedback spec, and sound deliverables guide.
- KAN-76: Added the project-local ElevenLabs Free SFX skill with KAN-76 event prompts, MP3 candidate output paths, API-key `.env` handling, dry-run support, and JSONL manifest recording for QA/draft sound candidates before KAN-75 Asphalt upload.

### Validation

- KAN-75 static validation passed: `rojo build default.project.json -o build/game.rbxl` passed, `git diff --check` passed with existing LF to CRLF warnings only, and TOML parsing passed with the bundled Python runtime. Asphalt cloud/debug sync is pending because `asphalt`/`rokit` are not installed on the local PATH and no delivered audio file or `ASPHALT_API_KEY` is available in this session.
- KAN-76 ElevenLabs skill validation passed: dry-run generated all seven planned event paths/prompts, Python AST syntax validation passed, skill frontmatter validation passed, missing `ELEVENLABS_API_KEY` exits with clear `.env` guidance, and `.env` is confirmed ignored by git. `quick_validate.py` could not run because the bundled Python runtime lacks PyYAML, and bytecode compilation was avoided because `.agents/skills` denies `__pycache__` writes under the current ACL.

## 2026-05-25

### Changed

- KAN-59: Added in-game 2D sprite rotation so the player sprite follows movement direction and enemy sprites face their current target player without changing KAN-57/KAN-58 asset ids, movement, hitboxes, combat ranges, or spawn rules.
- KAN-59: Corrected sprite rotation by 180 degrees after Studio QA and strengthened player character body transparency so the Roblox character rig remains hidden behind the 2D sprite.
- V0.4 Confluence audit: Updated the roadmap and V0.4 tracking pages after KAN-54/KAN-57/KAN-58/KAN-59 completion, with KAN-55 recorded as the remaining HUD badge polish implementation/QA item and KAN-56 tracked separately as a design-process task.
- V0.4 tracking: Marked KAN-55 complete per user confirmation and recorded KAN-56 as a separate design-process backlog item outside the current project stage.
- Jira cleanup: Marked KAN-8, KAN-12, and KAN-16 complete per user direction, with worklog notes on each issue.
- Jira cleanup: Marked KAN-2 complete after confirming there were no remaining open child issues under the V0.3 Epic.
- V0.4 closure: Marked KAN-14 complete, updated the V0.4 Confluence page and roadmap to completed status, and removed KAN-56 from the V0.4 Epic as a standalone backlog item.
- V1.0 planning: Created Jira Epic KAN-60, completed planning task KAN-61, added the V1.0 parent Confluence page, created eight child feature/release/QA documents, and linked them from the roadmap.
- V1.0 planning: Refined the V1.0 Confluence pages from the deep-interview results, created implementation tickets KAN-62 through KAN-69, created planning record KAN-70, and added design request tickets KAN-71 through KAN-73 for enemy variants, growth icons, and combat feedback VFX.
- KAN-62: Marked the V1.0 first-play flow complete by user confirmation under the current criteria, with follow-up regression coverage left to the V1.0 integration QA ticket KAN-69.
- KAN-63: Tuned the V1.0 survival-session wave curve around a 600-second target, adding staged spawn pressure so the first run ramps toward the 3-5 minute difficulty band while late-session pressure remains high for 10-minute survival.
- KAN-64: Added Basic/Fast/Tank enemy role definitions, time-based enemy mix weights, and sprite size/color fallback visuals so V1.0 difficulty can rely on role pressure instead of enemy count alone.
- KAN-63/KAN-64: Increased early difficulty after QA feedback by lowering the initial spawn interval, raising active enemy caps, introducing FastSlime from the first wave, introducing TankSlime from 60 seconds, and increasing special slime movement speed.
- KAN-64: Raised enemy health and movement speed after QA feedback so Basic/Fast/Tank slimes apply more durable pursuit pressure without changing contact damage, XP rewards, or spawn weights.
- KAN-74: Added a Studio-only camp QA reset button plus a server-validated `ResetMetaProgression` RemoteEvent so full first-run testing can restore the default meta progression snapshot and refresh camp UI state.
- KAN-65: Added the `Camp Spoils` reward growth choice, reward-multiplier state, percent-formatted level-up text, and run-end reward scaling so the V1.0 choice pool covers attack, reward, recovery, and utility directions.
- KAN-54: Adjusted V0.4 camp/result UI safe areas so camp resource rows/cards sit lower inside the main panel and run-result text no longer collides with the panel frame or Camp button.
- KAN-57/KAN-58: Marked the delivered in-game goblin and monster 2D PNG design requests complete in Jira after prior Tarmac upload and code application records.
- KAN-59: Created a follow-up Jira ticket for player character sprite rotation behavior without changing the delivered KAN-57/KAN-58 image assets.
- KAN-75: Created a separate V1.0 tooling ticket for the Asphalt-based sound/audio asset registration pipeline, linked it to KAN-66, and recorded the handoff on the Confluence combat feedback page.
- KAN-75: Added a Confluence sound deliverables guide for sound-team handoff, covering request/delivery tables, V1.0 KAN-66 event file names, Asphalt upload ownership, and Roblox audio QA criteria.

### Validation

- KAN-59 validation passed: `git diff --check` passed, `rojo build default.project.json -o build\game.rbxl` passed, and user Studio visual QA confirmed player/enemy sprite rotation plus player rig transparency.
- KAN-63 static validation passed: `rojo build default.project.json -o build\game.rbxl` passed and `git diff --check` passed with existing LF to CRLF warnings only. Studio playtest tuning remains pending.
- KAN-64 static validation passed: `rojo build default.project.json -o build\game.rbxl` passed and `git diff --check` passed with existing LF to CRLF warnings only. Studio visual/playtest QA remains pending.
- KAN-74 static validation passed: `rojo build default.project.json -o build\game.rbxl` passed and `git diff --check` passed with existing LF to CRLF warnings only. Studio click QA for the reset button remains pending.
- KAN-64 Studio QA passed by user verification: Basic/Fast/Tank monster variants appear correctly and their role-based presentation is acceptable for V1.0 completion.
- KAN-74 Studio QA passed by user verification: the Reset QA button works for complete initial-state testing.
- KAN-63 was closed per user direction after the wave/enemy pressure tuning pass; remaining full-loop survival validation stays under the V1.0 integration QA track.
- KAN-65 static validation passed: `rojo build default.project.json -o build\game.rbxl` passed and `git diff --check` passed with existing LF to CRLF warnings only. Studio level-up choice QA remains pending.
- KAN-65 Studio QA passed by user verification: `Camp Spoils` appears in level-up choices and increases run-end rewards.
- KAN-54 validation passed: `git diff --check` passed, `rojo build default.project.json -o build\game.rbxl` passed, and user Studio visual QA confirmed the camp/result UI placement after iterative safe-area adjustments.

## 2026-05-20

### Changed

- KAN-17: Regenerated the V0.4 camp hub background with `persona-agent-team-designer` design artifacts, uploaded it through Tarmac, and updated `Assets.lua` from `rbxassetid://83096712472280` to `rbxassetid://106508962052444`.
- KAN-54: Adjusted camp hub and run-result UI text safe areas from user screenshots so labels sit inside the panel/button artwork, with scaled button labels for tighter PC/mobile layouts.
- KAN-57/KAN-58: Registered V0.4 in-game 2D character assets through Tarmac, added `Assets.v0_4.ingame_2d` entries, and applied the goblin player/default monster sprites to combat display.
- KAN-57/KAN-58: Increased combat sprite display sizes and reduced the top-down camera height from 72 to 64 so the new 2D images are readable without changing movement, hitbox, attack range, or spawn rules.

### Validation

- KAN-17 asset validation passed: final PNG is 960x720, SHA-256 `2584ff36759f03673c5e6615198459aa016de6e91481a623f45bc7a1b7887d68`, and `rojo build default.project.json -o build\game.rbxl` passed. Roblox Studio PC/mobile visual QA remains pending.
- KAN-54 static/build validation passed: `git diff --check` passed and `rojo build default.project.json -o build\game.rbxl` passed. Roblox Studio screenshot QA remains pending.
- KAN-57/KAN-58 asset application passed static/build validation: Tarmac uploaded `rbxassetid://125657519388441` and `rbxassetid://132893170082324`; both PNGs are 512x512 with alpha, `git diff --check` passed, and `rojo build default.project.json -o build\game.rbxl` passed. Roblox Studio visual/application QA remains pending.

## 2026-05-19

### Added

- KAN-52: Added the V0.4 artifact 1-slot equip loop with `SwiftCharm` movement speed, `BlastCore` weak explosion, server-validated equip/unequip, default artifact ownership, run-start effect application, and camp UI artifact controls.
- KAN-52: Combined `BlastCore` with the V0.3 `ExplosiveBolt` upgrade by summing explosion damage to 65% and using radius 14 when both effects are active.

### Validation

- KAN-52 static/build QA passed: `git diff --check` passed and `rojo build default.project.json -o build\game.rbxl` passed.
- KAN-52 Studio runtime QA passed by user verification: artifact effects apply correctly in game.

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
