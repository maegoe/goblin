# Changelog

## 2026-06-26

### Changed

- KAN-99: Expanded camp level and persistent upgrade caps from short V1.0 limits to 10 levels, extending camp material and Growth Stone cost curves while preserving existing upgrade types, per-level stat gains, saved data shape, camp actions, and numeric level/cost/MAX UI flow.
- KAN-98: Updated the in-arena player goblin sprite state selection so the character returns to the idle sprite sheet when movement input is released, while preserving existing keyboard/D-pad left/right/up/down mapping and conflict handling. Mobile joystick movement now falls back to `Humanoid.MoveDirection` for walk/idle selection.

### Validation

- KAN-99 validation passed: `rojo build default.project.json -o build/game.rbxl` passed, `git diff --check` passed, Studio MCP Edit-mode module inspection confirmed camp max/cost count, MaxHealth max/cost count, and AttackDamage max/cost count are all 10 in the freshly built place, and Studio Play client UI inspection confirmed camp/upgrade numeric labels display `0 / 10`. Studio Play purchase/save/restore QA remains a follow-up check.
- KAN-98 validation passed: `rojo build default.project.json -o build/game.rbxl` passed, `git diff --check` passed, and manual PC Studio Play QA confirmed the player goblin returns to idle after movement input is released. Mobile Studio Play QA remains a follow-up check.

## 2026-06-17

### Changed

- KAN-95 follow-up: Replaced the supplied-image combat HUD treatment with a Roblox built-in UI component layout using layered frames, `UICorner`, `UIStroke`, `UIGradient`, `UIScale`, compact stat pills, and a forest-tuned fantasy palette while preserving existing health, XP, level, and survival-time data flow.  
- KAN-96 follow-up: Tuned the camp UI black-box treatment into a forest fantasy Roblox UI style with moss panels, olive strokes, rounded corners, subtle gradients, and warmer text colors while preserving numeric upgrade display and existing camp actions.  
- KAN-97: Added a client loading screen before the main camp UI and preload pass for registered image/audio/runtime asset ids from `Assets.lua`, `AudioAssets.luau`, arena, enemy, weapon, and player sprite references. Follow-up keeps the loading page visible for at least 5 seconds, while still waiting longer when asset preload takes more time.

### Validation

- KAN-95 follow-up validation passed: `rojo build default.project.json -o build/game.rbxl` passed, `git diff --check` passed, and Studio MCP Play QA confirmed the HUD is top-right within the viewport, respects the Roblox top inset, uses the forest palette preview from `KAN95_hud_forest_palette_preview`, and updates Level, Time, HP, and XP values/fill ratios.  
- KAN-96 follow-up validation passed: `rojo build default.project.json -o build/game.rbxl` passed and `git diff --check` passed; Studio MCP visual/runtime QA is pending for the camp UI palette pass.
- KAN-97 validation passed: `rojo build default.project.json -o build/game.rbxl` passed, `git diff --check` passed, and Studio MCP Play QA confirmed `GoblinLoading` is removed after preload while `GoblinCamp` is shown and HUD/result UI stay hidden before a run. Follow-up Studio MCP Play QA confirmed the minimum loading duration with `[goblin] Loading screen completed in 5.03s`. Local Studio asset permission limitations produced preload warnings, so the final implementation records those warnings as a single summary and still allows game entry.


## 2026-06-10

### Changed

- KAN-92: Recorded completion of the V1.0 unit opacity hotfix after user confirmation; enemy combat sprites remain opaque after damage.
- KAN-93: Recorded completion of the V1.0 orc display-size hotfix after user confirmation; TankSlime/orc reads larger while gameplay values remain unchanged.
- KAN-94: Recorded completion of the V1.0 level-up choice movement-lock hotfix after user confirmation; player movement is blocked while choices are pending and restored after selection.
- KAN-95: Replaced the in-arena health, XP, and separate level badge HUD with the supplied cartoon HUD image, adding live HP/EXP fill overlays and compact level text while preserving player stat calculations. Follow-up positioned the HUD at the top-right and scaled it smaller for touch/mobile or small viewports; an additional mobile follow-up reduced the mobile HUD scale to one quarter of the previous mobile size.
- KAN-96: Replaced fixed camp panel/card/slot background images with black Roblox UI box containers and changed persistent upgrade progress bars to numeric level/cost/owned resource text while preserving existing camp actions and asset icons.

### Validation

- KAN-92/KAN-93/KAN-94 completion is based on user confirmation following the prior implementation record for commit `02c4f9f`, prior `rojo build default.project.json -o build\game.rbxl` PASS, and prior `git diff --check` PASS with existing LF-to-CRLF working-copy warnings only.
- KAN-95 validation passed: uploaded `assets/v1_0/hud/goblin_cartoon_hud_256x128_v4.png` as `rbxassetid://79358805425016`, verified the source PNG as 256x128 ARGB with transparent background samples, `rojo build default.project.json -o build\game.rbxl` passed, `git diff --check` passed with existing LF-to-CRLF working-copy warnings only, and user Studio visual/runtime QA confirmed completion. The additional mobile scale follow-up also passed `rojo build default.project.json -o build\game.rbxl` and `git diff --check` with existing LF-to-CRLF warnings only.
- KAN-96 validation passed: `rojo build default.project.json -o build\game.rbxl` passed, `git diff --check` passed with existing LF-to-CRLF working-copy warnings only, and user confirmed completion after the black-box camp UI and numeric upgrade display pass.

## 2026-06-09

### Changed

- KAN-56: Closed the 2D image generation optimization backlog item after resolving the design-process need with an Open Design open-source workflow.

### Validation

- KAN-56 completion is based on user confirmation. No code, Roblox asset, Tarmac, or Studio QA change was required for this process-only backlog item.
## 2026-06-07

### Changed

- KAN-68: Extended GitHub Actions deployment so pushes to `dev` build with Rojo and publish to a separate development place through Roblox Open Cloud, while `main` continues to target the production place.
- KAN-68: Documented the required `development` GitHub Environment variables, including `ROBLOX_DEV_PLACE_ID`, and noted that current official Open Cloud place publishing updates existing places rather than creating new places.
- KAN-68: Switched GitHub Actions Rokit installation to `rokit install --no-trust-check` so CI can install trusted project tools non-interactively.
- KAN-68: Renamed the deployment secret expected by GitHub Actions to `ROBLOX_OPEN_CLOUD_API_KEY` and documented Luau Execution requirements for creating a development validation place with `AssetService:CreatePlaceAsync`.

### Validation

- KAN-68 local validation passed: `rojo build default.project.json -o build\game.rbxl` passed and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only.
- KAN-68 Open Cloud validation place creation passed: Luau Execution `AssetService:CreatePlaceAsync("Goblin Develop Verification", 127824265746134, ...)` created development validation place `99922439308375`, and local Open Cloud Place Publishing posted `build\game.rbxl` to published version `2`.
- KAN-68 GitHub Actions e2e deployment passed: rerun `27080749380` attempt 2 injected `ROBLOX_OPEN_CLOUD_API_KEY`, `ROBLOX_UNIVERSE_ID=10140717148`, and `ROBLOX_PLACE_ID=99922439308375`, built with Rojo, and published to Roblox with response `{"versionNumber":2}`.

## 2026-06-06

### Changed

- KAN-87: Recorded completion of the V1.0 unit/tile/goblin sprite sheet asset handoff after the corrected transparent goblin assets and previously delivered enemy/tile assets were accepted.
- KAN-88: Recorded completion of the V1.0 unit/effect/tile runtime sprite integration after successful Studio visual/runtime QA.

### Validation

- KAN-87/KAN-88 QA passed by user verification: corrected transparent player goblin sprites, enemy sprite sheets, attack explosion VFX, and arena floor tile runtime visuals are accepted for the KAN-88 scope.
- KAN-81 QA passed by user verification: PC/mobile level-up choice UI readability, horizontal choice-card layout, growth icon/fallback display, choice selection, growth effect application, and combat resume flow are accepted for the V1.0 hotfix scope.

## 2026-06-05

### Added

- KAN-90: Set the V1.0 mobile screen orientation to `LandscapeSensor` through `StarterGui` project configuration and a client startup orientation controller that keeps the current player's `PlayerGui.ScreenOrientation` in landscape-only mode.

### Changed

- KAN-91: Added V1.0 hotfix enemy movement behavior so BasicSlime, FastSlime, and TankSlime no longer rotate their combat sprites toward the player while pursuing.
- KAN-91: Added type-specific enemy collision radii and server-side enemy-to-enemy separation during pursuit so enemies avoid fully overlapping while preserving existing stats, spawn rules, rewards, sprite assets, contact damage, and arena clamps.
- KAN-88/KAN-87 follow-up: Updated the in-arena player goblin idle, walk-left, and walk-right sprite sheet runtime assets to the corrected transparent KAN-87 comment 10902 handoff ids `rbxassetid://118274519536442`, `rbxassetid://139275661229908`, and `rbxassetid://90889400666043`, preserving the existing 1024x128 8-frame metadata, input-state behavior, player sprite size, and fallback path.

### Validation

- KAN-90 static validation passed: `rojo build default.project.json -o build\game.rbxl` passed and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only.
- KAN-90 Studio/mobile QA passed by user verification: mobile landscape-only orientation works as intended, so portrait mode is blocked for V1.0 mobile play.
- KAN-91 static validation passed: `rojo build default.project.json -o build\game.rbxl` passed and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only. Studio runtime QA remains pending for visual rotation lock, enemy-to-enemy collision/spacing, and contact damage regression.
- KAN-91 Studio runtime QA passed by user verification: unit sprite rotation lock and unit-to-unit collision behavior work as intended.
- KAN-88/KAN-87 corrected player goblin asset static validation passed: `rojo build default.project.json -o build\game.rbxl` passed and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only. Studio visual/runtime QA should confirm the corrected transparent idle/walk-left/walk-right sheets render without chroma-key background.

## 2026-06-03

### Added

- KAN-83: Registered `assets/v0_4/camp_ui/slime-monster-idle-10f-sheet.png` through Tarmac as `rbxassetid://136162799387455` and added the generated asset reference `Assets.v0_4.camp_ui.slime_monster_idle_10f_sheet`.
- KAN-87: Created a follow-up BasicSlime idle sprite sheet v2 design request after KAN-85 found the KAN-83 5120x512 sheet unsuitable for runtime sprite application.
- KAN-88: Created a consolidated runtime sprite sheet implementation ticket for the goblin character, BasicSlime via KAN-87, FastSlime-to-bat, TankSlime-to-orc, and attack explosion VFX via KAN-86.

### Changed

- KAN-72: Generated the V1.0 growth choice icon PNG set with imagegen and chroma-key alpha conversion, uploaded all five files through Tarmac/Open Cloud using the `.env` Open Cloud key, and registered the resulting ids under `Assets.v1_0.growth_icons`.
- KAN-72/KAN-81: Wired the level-up choice cards to use the registered growth icon assets when available while preserving fallback text labels for missing or unloaded asset registry entries.
- KAN-80: Added short-lived floating damage number billboards when enemies take damage, covering both direct bolt hits and explosion splash damage.
- KAN-81: Changed the level-up choice UI from plain vertical buttons to responsive choice cards: three horizontal cards on wide screens, vertical cards on mobile/portrait screens, with stable icon areas and fallback text icons mapped to each growth choice.
- KAN-79: Removed jump behavior by disabling Humanoid jumping on server/client and hiding the default mobile JumpButton.
- KAN-78: Added shared arena bounds, generated invisible boundary walls, clamped enemy spawn/movement positions inside the finite arena, and required clamped spawn positions to stay away from the player.
- KAN-77: Treat Roblox respawn/reset during an active in-game run as immediate Defeat, using the existing run-result and reward flow instead of restoring the player to full health.
- KAN-82: Rebalanced the in-game player and enemy monster 2D sprite display sizes after Studio feedback by scaling the quarter-size hotfix up 1.5x, while leaving asset ids, hitboxes, movement, attack range, spawn rules, and balance values unchanged.
- KAN-84: Made the in-game PlayerSpawn fully transparent and aligned its height with the arena floor to remove the visible spawn pad step without changing spawn behavior, arena bounds, or spawn rules.
- KAN-88: Replaced the attack explosion feedback image with the KAN-86 firework hit sprite sheet runtime VFX, playing eight 128x128 frames over the existing explosion feedback duration while preserving damage, radius, projectile, reward, and fallback logic.
- KAN-88/KAN-86 follow-up: Updated the attack explosion VFX runtime asset to the KAN-86 transparent firework sprite variant `rbxassetid://115637673020473` after the previous registered asset had an incorrect background.
- KAN-88/KAN-87 follow-up: Replaced BasicSlime, FastSlime, and TankSlime in-game single-image enemy visuals with the KAN-87 1024x128 8-frame sprite sheets while preserving enemy stats, hitboxes, spawn rules, movement, contact damage, rewards, and existing KAN-82 display sizes.
- KAN-88/KAN-87 follow-up: Applied the delivered map floor tile asset `rbxassetid://99437972869009` as a repeated top-face texture on the existing ArenaFloor while preserving arena size, floor height, collision, spawn, enemy spawn, and movement clamp contracts.
- KAN-88/KAN-87 follow-up: Added Studio-only ArenaFloor tile diagnostics under the `[goblin][ArenaFloorTile]` Output prefix, including floor/texture creation state, configured texture id, face, tile scale, parent path, and ContentProvider preload status for the map tile asset.
- KAN-88/KAN-87 follow-up: Updated the ArenaFloor tile runtime asset from `rbxassetid://99437972869009` to the newer KAN-87 comment handoff asset `rbxassetid://89096359055479`, preserving the existing repeat scale, diagnostics, arena size, floor height, collision, spawn, enemy spawn, and movement clamp contracts.
- KAN-89: Reorganized the lobby/camp UI into a single reading flow: top resource/status board, left growth and fixed artifact board, and right next-run action board with `Start Run` as the only primary CTA.
- KAN-89: Changed maxed growth cards to hide their `Buy` buttons and show MAX/completion state with a full progress bar, while lower-priority camp upgrades use secondary/disabled button states.
- KAN-88/KAN-87 follow-up: Replaced the in-arena player goblin single-image combat sprite with the KAN-87 comment handoff idle, walk-left, and walk-right 8-frame sprite sheets, including keyboard/D-pad state selection, startup idle playback, four-direction conflict handling, and first-frame stop behavior when movement input is released.
- KAN-81 follow-up: Tightened level-up choice card icon and title presentation by making the icon background box square, coloring its border with the choice rarity color, and forcing choice titles to stay on one line with scaled-down text for longer names.
- KAN-81 follow-up: Increased level-up choice title readability by giving one-line titles a wider card area in horizontal layout and raising their text size floor while preserving the one-line constraint.
- KAN-81 follow-up rollback: Reverted the level-up choice title-specific layout and text-size changes, restoring the previous wrapped title area while keeping the square icon box and rarity-colored icon border changes.
- KAN-88 progress update: Completed all non-character sprite runtime updates currently in scope: BasicSlime, FastSlime, TankSlime, and attack explosion VFX. The remaining sprite implementation target is the goblin character, with Studio visual/runtime QA still pending.
- No-ticket hotfix: Changed the goblin growth display wording from `Stage` to `Level` in the HUD and camp UI while keeping the existing appearance-stage payload compatible.

### Validation

- KAN-83 validation passed: `slime-monster-idle-10f-sheet.png` verified as 5120x512 PNG RGBA with alpha matching a 10-frame 512x512 idle sheet layout, Tarmac Roblox sync uploaded `rbxassetid://136162799387455`, `tarmac --api-key "$ROBLOX_API_KEY" sync --target none tarmac.toml` passed after upload, `rojo build default.project.json -o build/game.rbxl` passed, and `git diff --check` passed.
- KAN-85 was returned to `할 일` after Studio/runtime review found the KAN-83 5120x512 sprite sheet unsuitable for runtime sprite application. Follow-up design request KAN-87 now blocks KAN-85 and requests a 960x720 v2 BasicSlime idle sheet with 240x240 frames.
- KAN-85 was closed as superseded by KAN-88. KAN-88 now tracks the multi-unit/effect sprite sheet runtime conversion, with KAN-87 blocking the BasicSlime portion and KAN-86 related to attack explosion VFX.
- KAN-88 attack explosion VFX partial validation passed: `rojo build default.project.json -o build\game.rbxl` passed and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only. Studio visual/runtime QA remains pending, and the non-explosion KAN-88 unit sprite targets remain open.
- KAN-88/KAN-86 transparent explosion asset update validation passed: `rojo build default.project.json -o build\game.rbxl` passed and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only. Studio visual/runtime QA for the transparent variant remains pending.
- KAN-88/KAN-87 enemy sprite animation validation passed: `rojo build default.project.json -o build\game.rbxl` passed and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only. Studio visual/runtime QA for BasicSlime, FastSlime, and TankSlime sprite playback remains pending.
- KAN-88/KAN-87 map floor tile static validation passed: `rojo build default.project.json -o build\game.rbxl` passed using the Rokit tool-storage Rojo 7.6.1 binary after the Rokit shim returned `os error 3`, and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only. Studio visual/runtime QA should confirm tile scale/alignment and unchanged arena movement/spawn behavior.
- KAN-88/KAN-87 map tile diagnostics validation passed: `rojo build default.project.json -o build\game.rbxl` passed using the Rokit tool-storage Rojo 7.6.1 binary, and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only. Studio Output should be checked for `[goblin][ArenaFloorTile]` lines during Play.
- KAN-88/KAN-87 map floor tile Studio QA passed by user verification: the delivered floor tile now applies correctly in Studio/runtime.
- KAN-88/KAN-87 map floor tile asset replacement static validation passed: `rojo build default.project.json -o build\game.rbxl` passed using the Rokit tool-storage Rojo 7.6.1 binary, and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only. Studio visual/runtime QA should confirm the new `rbxassetid://89096359055479` tile appears correctly.
- KAN-89 static validation passed: `rojo build default.project.json -o build\game.rbxl` passed using the Rokit tool-storage Rojo 7.6.1 binary, and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only. Studio PC/mobile visual and click-flow QA remains pending.
- KAN-88/KAN-87 player goblin sprite static validation passed: `rojo build default.project.json -o build\game.rbxl` passed using the Rokit tool-storage Rojo 7.6.1 binary, and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only. Studio visual/runtime QA should confirm idle/walk-left/walk-right playback and the specified input conflict behavior.
- KAN-81 follow-up static validation passed: `rojo build default.project.json -o build\game.rbxl` passed using the Rokit tool-storage Rojo 7.6.1 binary, and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only. Studio PC/mobile rendered UI QA remains pending for square icon boxes, rarity-colored icon borders, and one-line scaled titles.
- KAN-81 title readability follow-up static validation passed: `rojo build default.project.json -o build\game.rbxl` passed using the Rokit tool-storage Rojo 7.6.1 binary, and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only. Studio PC/mobile rendered UI QA should confirm one-line titles are no longer over-shrunk.
- KAN-81 title rollback static validation passed: `rojo build default.project.json -o build\game.rbxl` passed using the Rokit tool-storage Rojo 7.6.1 binary, and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only.
- KAN-88 non-character sprite scope is implementation-complete from static validation evidence. Do not close KAN-88 yet: goblin character sprite implementation and Studio visual/runtime QA remain open.
- KAN-72 validation passed: initial registry check found no existing KAN-72 asset entries, all five generated PNGs validated as 128x128 RGBA with transparent corners and non-empty foreground coverage, Tarmac/Open Cloud upload succeeded, `Assets.lua`/`tarmac-manifest.toml` were merged to preserve existing v0_4 registry entries while adding only `v1_0.growth_icons`, `rojo build default.project.json -o build\game.rbxl` passed, and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only. Studio rendered UI QA remains pending.
- KAN-80 validation passed: `rojo build default.project.json -o build\game.rbxl` passed, `git diff --check` passed with existing LF-to-CRLF working-copy warnings only, and user Studio runtime QA confirmed damage numbers are readable, match applied damage, do not overly obscure combat, and preserve enemy death/reward/level-up flow.
- KAN-81 static validation passed: `rojo build default.project.json -o build\game.rbxl` passed and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only. Studio PC/mobile level-up UI readability and selection-flow QA remain pending.
- KAN-79 validation passed: `rojo build default.project.json -o build\game.rbxl` passed, `git diff --check` passed with existing LF-to-CRLF working-copy warnings only, and user Studio runtime QA confirmed JumpButton is hidden, default jump input does not jump, and baseline combat movement still works.
- KAN-78 static validation passed after the player-near spawn fix: `rojo build default.project.json -o build\game.rbxl` passed and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only. Studio boundary collision and repeated spawn runtime QA remain pending.
- KAN-77 validation passed: `rojo build default.project.json -o build\game.rbxl` passed, `git diff --check` passed with existing LF-to-CRLF working-copy warnings only, and user Studio runtime QA confirmed reset/respawn immediately enters the existing defeat result and reward flow.
- KAN-82 validation passed after the 1.5x sprite-size adjustment: `rojo build default.project.json -o build\game.rbxl` passed and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only. User accepted the adjusted Studio visual size for completion.
- KAN-84 static validation passed: `rojo build default.project.json -o build\game.rbxl` passed and `git diff --check` passed with existing LF-to-CRLF working-copy warnings only. Studio visual QA should confirm PlayerSpawn is invisible and flush with the arena floor.
- `rojo build default.project.json -o build\game.rbxl` passed.
- `git diff --check` passed with existing LF-to-CRLF working-copy warnings only.

## 2026-05-31

### Changed

- KAN-75/KAN-66 follow-up: Added `background_music_sample.mp3` under `assets/audio/v1_0/music/` for Asphalt audio registration and wired a client background music controller that loops `AudioAssets.v1_0.music.background_music_sample` when the generated Roblox audio asset id is available.
- KAN-75/KAN-66 follow-up: Uploaded the background music MP3 through Asphalt and generated `rbxassetid://109169515800716`.
- KAN-66 follow-up: Changed background music playback from a single hard loop to two alternating `Sound` instances with 1.5s fade in/out crossfade to mask imperfect MP3 loop seams.
- KAN-75/KAN-66 follow-up: Replaced the background music source with the Audacity fade-adjusted WAV and uploaded it through Asphalt as `rbxassetid://139886475979592`.

### Validation

- Local Asphalt debug sync passed with the direct Rokit-managed Asphalt 2.0.0 binary and included `assets/audio/v1_0/music/background_music_sample.mp3`.
- Asphalt cloud sync uploaded the new background music asset and post-upload `asphalt sync cloud --dry-run` reported no new assets.
- `rojo build default.project.json -o build\game.rbxl` passed.
- Background music crossfade static validation passed with `rojo build default.project.json -o build\game.rbxl` and `git diff --check`.
- WAV replacement validation passed: `asphalt sync debug`, `asphalt sync cloud`, post-upload `asphalt sync cloud --dry-run`, and `rojo build default.project.json -o build\game.rbxl`.

## 2026-05-30

### Changed

- KAN-76: Accepted the seven ElevenLabs Free MP3 SFX files as the V1.0 QA candidate audio set after user listening QA, and recorded the completion decision in Confluence and Jira.
- KAN-75: Ran the Asphalt cloud sync against the accepted KAN-76 MP3 candidates, generating `asphalt.lock.toml` and `src/shared/AudioAssets.luau` with seven Roblox audio asset ids.
- KAN-75: Recorded user-confirmed Roblox Studio `Sound.SoundId` playback QA PASS for all seven generated audio assets.
- KAN-66: Connected the seven V1.0 feedback audio events through `FeedbackAudioController`, a server `FeedbackService`, and the generated `AudioAssets.luau` ids.
- KAN-66: Recorded user Studio runtime QA PASS for all seven in-game feedback audio triggers.
- KAN-67: Hardened MetaProgression fallback behavior so DataStore save failures keep the server-authoritative memory snapshot active for QA, expose the last storage error, and save all active sessions on shutdown.

### Validation

- KAN-76 user listening QA passed for the current V1.0 QA candidate set. V1.0 will use these QA candidates; KAN-75 Asphalt upload and KAN-66 runtime hookup remain separate follow-up work.
- KAN-75 Asphalt pipeline validation passed: `asphalt sync debug` processed all seven MP3s, `asphalt sync cloud` uploaded them, post-upload `asphalt sync cloud --dry-run` reported no new assets, `rojo build default.project.json -o build\game.rbxl` passed, `git diff --check` passed with the existing `CHANGELOG.md` LF to CRLF warning only, and user Studio playback QA confirmed every generated `Sound.SoundId` asset plays successfully.
- KAN-66 validation passed: `rojo build default.project.json -o build\game.rbxl` passed, `git diff --check` reported only existing LF to CRLF warnings, and user Studio runtime QA confirmed all seven in-game event triggers play successfully.
- KAN-67 validation passed: `rojo build default.project.json -o build\game.rbxl` passed, `git diff --check` reported only existing LF to CRLF warnings, user Studio DataStore stop/start persistence QA confirmed values are retained, and user Studio API Services disabled fallback QA confirmed warning logs do not block gameplay while current-session values are still reflected.

## 2026-05-29

### Changed

- KAN-76: Generated all seven ElevenLabs Free QA/draft MP3 SFX candidates for the V1.0 combat feedback request under `assets/audio/v1_0/...`, with JSONL manifest records in `_workspace/goblin-dev/sfx-generation-manifest.jsonl`.

### Validation

- KAN-76 candidate generation recorded each output as `free-plan-qa-candidate` with `commercial_use: not-cleared`. `camp_purchase_01.mp3` was generated at 0.5s instead of the default 1.0s to stay within the remaining Free tier credit quota; listening QA, commercial-use clearance, KAN-75 Asphalt upload, and KAN-66 runtime hookup remain pending.

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
