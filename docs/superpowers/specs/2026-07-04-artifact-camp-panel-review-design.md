# KAN-112/KAN-113 Artifact Camp Panel Review Design

## Context

`KAN-112` and `KAN-113` cover artifact icon and inventory work for existing artifacts such as `Swift Charm` and `Blast Core`.

Local code already has:

* `src/shared/ArtifactDefinitions.lua` with `SwiftCharm` and `BlastCore`, display names, descriptions, and icon asset keys.
* `src/shared/Assets.lua` with existing Roblox asset IDs for both artifact icons.
* `src/client/CampController.lua` with a compact camp artifact panel, equip buttons, and unequip behavior.

The review therefore narrows the product/design goal from a new inventory system to an improvement of the existing camp artifact panel.

## Approved Direction

Use a small always-visible artifact panel inside the existing camp screen. Do not add a modal, separate inventory tab, full inventory page, active-run inventory, new artifact effects, artifact acquisition changes, or equipment slot expansion.

The chosen behavior is a simple expanded current panel:

* Keep the current camp screen surface.
* Keep artifact management lobby/camp-only.
* Keep current artifact actions: equip `Swift Charm`, equip `Blast Core`, and unequip.
* Add or refine a compact description area inside the artifact panel.
* Use current artifact icons as fallback unless QA finds them unclear.

## KAN-113 Product Behavior

`KAN-113` should be framed as: improve the existing camp artifact panel with icon-backed artifact buttons and descriptions.

Default panel state:

* Shows the equipped artifact summary when an artifact is equipped.
* Shows an empty-state summary when no artifact is equipped.
* Keeps start-run flow and camp upgrade flow visible and unchanged.

Preview behavior:

* PC hover over an artifact control previews that artifact in the description area.
* Mobile tap/focus on an artifact control previews that artifact in the description area.
* When hover/focus leaves, the description area returns to the equipped artifact or empty-state summary.
* Activating an artifact control still equips it when owned.

Description content:

* Artifact display name.
* Owned/equipped/locked state.
* Current effect summary from `ArtifactDefinitions.Description`.
* No balance details beyond existing artifact definitions unless already present in config.

## KAN-112 Product Behavior

`KAN-112` should be narrowed to a conditional icon-quality task.

Current icons are accepted as fallback because `Assets.lua` already includes:

* `icon_artifact_swift_charm_default_256x256`
* `icon_artifact_blast_core_default_256x256`

Replacement production icons are requested only if PC/mobile QA finds the current icons unclear at the camp-panel display size.

If replacement is needed, the request should follow the UI design output guide:

* PNG only.
* 256x256 preferred.
* Transparent background.
* No 9-slice.
* No text embedded in the icon.
* Roblox asset ID handoff recorded in Jira and Confluence.

## Ticket Review Notes

Recommended `KAN-113` edits:

* Replace "artifact inventory" language with "existing camp artifact panel".
* Remove broad inventory-management wording that implies a new system.
* Keep hover/focus description requirements.
* Add acceptance criteria for returning preview state to equipped/empty summary.
* Add acceptance criteria that active-run HUD does not expose artifact management.

Recommended `KAN-112` edits:

* Record that current icons and asset IDs already exist.
* Change the goal from mandatory new icons to QA-gated replacement icons.
* Keep `Swift Charm` and `Blast Core` as the only required artifact icon review targets until more artifacts are added.
* Keep design guide handoff requirements if replacement icons are produced.

## Acceptance Criteria

* Camp screen remains a single screen with no new modal or inventory page.
* Artifact panel shows equipped/empty summary by default.
* Hover/tap/focus previews `Swift Charm` and `Blast Core` descriptions.
* Artifact equip and unequip behavior remains unchanged.
* Current artifact icons are used unless QA marks them unclear.
* PC and mobile QA verify panel readability, no overlap with existing camp controls, and no active-run inventory exposure.

