# Artifact Camp Panel Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve the existing camp artifact panel so it shows icon-backed artifact controls and a compact description area for `Swift Charm` and `Blast Core`.

**Architecture:** Keep the work inside the current camp screen and existing artifact services. `ArtifactDefinitions.lua` remains the source for names, descriptions, order, and icon keys; `CampController.lua` renders and previews that data; `Assets.lua` remains generated and is not manually edited.

**Tech Stack:** Roblox Luau, Rojo project layout, Jira/Confluence for delivery tracking, existing Studio QA flow.

---

## Scope Guard

This plan does not add a modal, inventory tab, full inventory page, active-run inventory, new artifacts, artifact acquisition, equipment slot expansion, or new QA automation.

The project currently has no unit-test harness for Luau UI controllers, and project instructions prohibit adding new QA automation unless explicitly scoped. Verification therefore uses static checks, Rojo build, Git diff checks, and Roblox Studio QA.

## File Structure

Modify:

* `src/client/CampController.lua`: render icon-backed artifact controls, persistent equipped/empty summary, and hover/tap/focus preview behavior.
* `CHANGELOG.md`: record the implementation result after verification.

Read only:

* `src/shared/ArtifactDefinitions.lua`: source for artifact display names, descriptions, icon keys, and order.
* `src/shared/Assets.lua`: generated Tarmac asset table; use existing icon asset IDs, do not edit manually.
* `docs/superpowers/specs/2026-07-04-artifact-camp-panel-review-design.md`: approved design source.

External updates:

* Jira `KAN-112`: narrow icon work to QA-gated replacement only.
* Jira `KAN-113`: narrow implementation to existing camp artifact panel.
* Confluence V1.0 page and CHANGELOG page: record implementation and QA outcome after verification.

---

### Task 1: Jira Scope Preparation

**Files:**

* No local files changed.
* Update Jira: `KAN-112`, `KAN-113`.

- [ ] **Step 1: Confirm current ticket state**

Use Atlassian Rovo JQL:

```jql
key in (KAN-112, KAN-113) ORDER BY key ASC
```

Expected: both issues exist under `KAN-60` and are not complete.

- [ ] **Step 2: Move scoped issues to in progress**

For each issue that is not already `진행 중` or `완료`, transition it to `진행 중`.

Expected: `KAN-112` and `KAN-113` are tracked as active before implementation starts.

- [ ] **Step 3: Add scope note to `KAN-112`**

Add this Jira comment:

```markdown
Scope refinement from approved design spec:

Current artifact icon asset keys and Roblox asset IDs already exist for `Swift Charm` and `Blast Core` in `src/shared/Assets.lua`. This ticket is QA-gated: use current icons as fallback, and request replacement production PNGs only if PC/mobile camp-panel QA finds the icons unclear at display size.

Design guide constraints remain: 256x256 PNG, transparent background, no 9-slice, no text embedded in icon, Roblox asset ID handoff recorded in Jira and Confluence if replacement icons are produced.
```

Expected: `KAN-112` no longer implies mandatory new icon production.

- [ ] **Step 4: Add scope note to `KAN-113`**

Add this Jira comment:

```markdown
Scope refinement from approved design spec:

Implement this as an improvement to the existing camp artifact panel, not as a new inventory system. Keep the panel always visible in lobby/camp. Keep current actions: equip `Swift Charm`, equip `Blast Core`, unequip. Add icon-backed artifact controls and a compact description area that shows equipped/empty summary by default and previews artifact details on PC hover or mobile tap/focus.

Excluded: modal, tab/page inventory, active-run inventory, new artifacts, artifact acquisition changes, artifact balance changes, and equipment slot expansion.
```

Expected: `KAN-113` is implementation-ready and aligned with the approved spec.

---

### Task 2: Artifact Summary Helpers

**Files:**

* Modify: `src/client/CampController.lua`
* Read: `src/shared/ArtifactDefinitions.lua`, `src/shared/Assets.lua`

- [ ] **Step 1: Add state variables for generic artifact buttons and preview**

In `src/client/CampController.lua`, replace:

```lua
local swiftArtifactButton
local blastArtifactButton
local unequipArtifactButton
```

with:

```lua
local artifactButtonsById = {}
local previewedArtifactId = nil
local unequipArtifactButton
```

Expected: the controller no longer needs one top-level variable per artifact.

- [ ] **Step 2: Add artifact icon and state helpers**

In `src/client/CampController.lua`, after `getArtifactDisplayName`, add:

```lua
local function getArtifactDefinition(artifactId)
	if type(artifactId) ~= "string" then
		return nil
	end

	return ArtifactDefinitions[artifactId]
end

local function getArtifactIcon(definition)
	if not definition or type(definition.IconAssetKey) ~= "string" then
		return campAssets.camp_slot_artifact_empty_256x256
	end

	local assetId = campAssets[definition.IconAssetKey]
	if type(assetId) == "string" then
		return assetId
	end

	return campAssets.camp_slot_artifact_empty_256x256
end

local function getArtifactStateLabel(progression, artifactId)
	if progression and progression.EquippedArtifactId == artifactId then
		return "Equipped", TEXT_SUCCESS
	end

	if ownsArtifact(progression, artifactId) then
		return "Owned", TEXT_LIGHT
	end

	return "Locked", TEXT_MUTED
end

local function formatArtifactSummary(progression, artifactId)
	local definition = getArtifactDefinition(artifactId)
	if not definition then
		return "Equipped Artifact\nEmpty\nNo artifact effect active."
	end

	local stateLabel = getArtifactStateLabel(progression, artifactId)
	return string.format(
		"%s\n%s\n%s",
		definition.DisplayName,
		stateLabel,
		definition.Description or "No description"
	)
end
```

Expected: description text is data-driven from `ArtifactDefinitions`.

- [ ] **Step 3: Add preview update helper**

In `src/client/CampController.lua`, after `formatArtifactSummary`, add:

```lua
local function updateArtifactSummary()
	if not artifactText then
		return
	end

	local progression = latestProgression or {}
	local artifactId = previewedArtifactId or progression.EquippedArtifactId
	artifactText.Text = formatArtifactSummary(progression, artifactId)
end
```

Expected: equipped/empty default and preview text share one update path.

---

### Task 3: Render Icon-Backed Artifact Controls

**Files:**

* Modify: `src/client/CampController.lua`

- [ ] **Step 1: Replace `setArtifactButtonState` with an icon-aware version**

Replace the current `setArtifactButtonState` function with:

```lua
local function setArtifactButtonState(button, artifactId, progression)
	if not button then
		return
	end

	local definition = ArtifactDefinitions[artifactId]
	local owned = ownsArtifact(progression, artifactId)
	local equipped = progression and progression.EquippedArtifactId == artifactId

	button.Active = owned
	button.Image = equipped and campAssets.camp_card_artifact_selected_512x256 or campAssets.camp_card_artifact_default_512x256
	button.ImageTransparency = owned and 0 or 0.35

	local icon = button:FindFirstChild("Icon")
	if icon and icon:IsA("ImageLabel") then
		icon.Image = getArtifactIcon(definition)
		icon.ImageTransparency = owned and 0 or 0.45
	end

	local label = button:FindFirstChild("Label")
	if label and label:IsA("TextLabel") then
		label.Text = definition and definition.DisplayName or "Unknown"
		label.TextColor3 = owned and TEXT_LIGHT or TEXT_MUTED
	end

	local state = button:FindFirstChild("State")
	if state and state:IsA("TextLabel") then
		local stateLabel, stateColor = getArtifactStateLabel(progression, artifactId)
		state.Text = stateLabel
		state.TextColor3 = stateColor
	end
end
```

Expected: each artifact control shows the artifact icon, display name, and state.

- [ ] **Step 2: Add an artifact-specific button factory**

In `src/client/CampController.lua`, after `createImageButton`, add:

```lua
local function createArtifactButton(parent, artifactId, position, size)
	local definition = ArtifactDefinitions[artifactId]
	local button = Instance.new("ImageButton")
	button.Name = "Artifact" .. artifactId
	button.BackgroundTransparency = 1
	button.Image = campAssets.camp_card_artifact_default_512x256
	button.Position = position
	button.Size = size
	button.ScaleType = Enum.ScaleType.Stretch
	button.AutoButtonColor = false
	button.Parent = parent

	local icon = createImage(button, "Icon", getArtifactIcon(definition), UDim2.fromScale(0.06, 0.18), UDim2.fromScale(0.22, 0.54))
	icon.ScaleType = Enum.ScaleType.Fit

	local label = createText(button, "Label", definition and definition.DisplayName or artifactId, UDim2.fromScale(0.32, 0.14), UDim2.fromScale(0.58, 0.35), 12)
	label.TextXAlignment = Enum.TextXAlignment.Left

	local state = createText(button, "State", "Owned", UDim2.fromScale(0.32, 0.52), UDim2.fromScale(0.58, 0.28), 10)
	state.TextXAlignment = Enum.TextXAlignment.Left

	return button
end
```

Expected: artifact controls are visually distinct from regular camp action buttons.

- [ ] **Step 3: Replace hardcoded artifact button creation**

In `buildCamp`, replace:

```lua
swiftArtifactButton = createImageButton(artifactCard, "EquipSwiftCharm", campAssets.camp_button_secondary_default_512x128, UDim2.fromScale(0.48, 0.21), UDim2.fromScale(0.18, 0.28), "Swift", 12)
blastArtifactButton = createImageButton(artifactCard, "EquipBlastCore", campAssets.camp_button_secondary_default_512x128, UDim2.fromScale(0.68, 0.21), UDim2.fromScale(0.18, 0.28), "Blast", 12)
unequipArtifactButton = createImageButton(artifactCard, "UnequipArtifact", campAssets.camp_button_secondary_default_512x128, UDim2.fromScale(0.56, 0.57), UDim2.fromScale(0.26, 0.25), "Unequip", 12)
```

with:

```lua
artifactButtonsById = {}
artifactButtonsById.SwiftCharm = createArtifactButton(artifactCard, "SwiftCharm", UDim2.fromScale(0.48, 0.15), UDim2.fromScale(0.2, 0.43))
artifactButtonsById.BlastCore = createArtifactButton(artifactCard, "BlastCore", UDim2.fromScale(0.7, 0.15), UDim2.fromScale(0.2, 0.43))
unequipArtifactButton = createImageButton(artifactCard, "UnequipArtifact", campAssets.camp_button_secondary_default_512x128, UDim2.fromScale(0.57, 0.64), UDim2.fromScale(0.28, 0.24), "Unequip", 12)
```

Expected: the artifact panel still fits inside `ArtifactBoard` and leaves the unequip action visible.

---

### Task 4: Preview and Equip Wiring

**Files:**

* Modify: `src/client/CampController.lua`

- [ ] **Step 1: Add preview event helper**

In `src/client/CampController.lua`, after `setArtifactButtonState`, add:

```lua
local function connectArtifactButton(button, artifactId)
	button.MouseEnter:Connect(function()
		previewedArtifactId = artifactId
		updateArtifactSummary()
	end)

	button.MouseLeave:Connect(function()
		if previewedArtifactId == artifactId then
			previewedArtifactId = nil
			updateArtifactSummary()
		end
	end)

	button.SelectionGained:Connect(function()
		previewedArtifactId = artifactId
		updateArtifactSummary()
	end)

	button.SelectionLost:Connect(function()
		if previewedArtifactId == artifactId then
			previewedArtifactId = nil
			updateArtifactSummary()
		end
	end)

	button.Activated:Connect(function()
		previewedArtifactId = artifactId
		updateArtifactSummary()
		if ownsArtifact(latestProgression, artifactId) then
			Remotes.get(Remotes.Names.EquipArtifact):FireServer(artifactId)
		end
	end)
end
```

Expected: PC hover, keyboard/gamepad focus, and mobile tap all preview artifact details.

- [ ] **Step 2: Replace hardcoded activation connections**

In `buildCamp`, replace:

```lua
swiftArtifactButton.Activated:Connect(function()
	if ownsArtifact(latestProgression, "SwiftCharm") then
		Remotes.get(Remotes.Names.EquipArtifact):FireServer("SwiftCharm")
	end
end)
blastArtifactButton.Activated:Connect(function()
	if ownsArtifact(latestProgression, "BlastCore") then
		Remotes.get(Remotes.Names.EquipArtifact):FireServer("BlastCore")
	end
end)
```

with:

```lua
connectArtifactButton(artifactButtonsById.SwiftCharm, "SwiftCharm")
connectArtifactButton(artifactButtonsById.BlastCore, "BlastCore")
```

Expected: both artifact controls use the shared preview and equip behavior.

- [ ] **Step 3: Update camp refresh logic**

In `updateCamp`, replace:

```lua
artifactText.Text = string.format("Equipped Artifact\n%s", getArtifactDisplayName(progression.EquippedArtifactId))
```

with:

```lua
if previewedArtifactId and not ArtifactDefinitions[previewedArtifactId] then
	previewedArtifactId = nil
end
updateArtifactSummary()
```

Then replace:

```lua
setArtifactButtonState(swiftArtifactButton, "SwiftCharm", progression)
setArtifactButtonState(blastArtifactButton, "BlastCore", progression)
```

with:

```lua
setArtifactButtonState(artifactButtonsById.SwiftCharm, "SwiftCharm", progression)
setArtifactButtonState(artifactButtonsById.BlastCore, "BlastCore", progression)
```

Expected: UI refresh keeps the preview text stable when valid and returns to equipped/empty summary when preview is cleared.

---

### Task 5: Static Verification

**Files:**

* Read/verify all changed local files.

- [ ] **Step 1: Inspect changed diff**

Run:

```powershell
git diff -- src\client\CampController.lua
```

Expected:

* Only `CampController.lua` implementation changes appear.
* No manual edits appear in generated `src/shared/Assets.lua`.
* Artifact logic remains camp-only.

- [ ] **Step 2: Build with Rojo**

Run:

```powershell
rojo build default.project.json -o build\game.rbxl
```

Expected:

```text
Built project to build\game.rbxl
```

If `rojo` is unavailable in PATH, run:

```powershell
rokit run rojo build default.project.json -o build\game.rbxl
```

Expected: the build completes and writes `build\game.rbxl`.

- [ ] **Step 3: Check whitespace**

Run:

```powershell
git diff --check
```

Expected: no new whitespace errors from the changed files. Existing unrelated line-ending warnings must be recorded in the QA notes if present.

---

### Task 6: Roblox Studio QA

**Files:**

* Use built place: `build/game.rbxl`.
* Record evidence in `_workspace/goblin-dev/KAN-113_qa.md`.

- [ ] **Step 1: Create QA note file**

Create `_workspace/goblin-dev/KAN-113_qa.md` with this structure:

```markdown
# KAN-113 QA

## Build

* `rojo build default.project.json -o build\game.rbxl`: NOT RUN
* `git diff --check`: NOT RUN

## Studio Runtime

* Camp artifact panel visible on entry: NOT RUN
* Equipped/empty summary shown by default: NOT RUN
* Swift Charm hover/tap/focus previews name, state, and effect: NOT RUN
* Blast Core hover/tap/focus previews name, state, and effect: NOT RUN
* Equip Swift Charm still works: NOT RUN
* Equip Blast Core still works: NOT RUN
* Unequip still works: NOT RUN
* Start Run hides camp artifact panel and active-run HUD has no inventory management: NOT RUN
* PC layout has no overlap with camp controls: NOT RUN
* Mobile-sized viewport has no overlap with camp controls: NOT RUN

## Icon QA

* Current Swift Charm icon readable at camp-panel size: NOT RUN
* Current Blast Core icon readable at camp-panel size: NOT RUN
* KAN-112 replacement icon request needed: NOT RUN
```

Expected: QA evidence has a fixed checklist tied to the approved design.

- [ ] **Step 2: Run Studio QA**

Open `build/game.rbxl` in Roblox Studio and start Play mode.

Expected results:

* Camp screen appears at player entry.
* Artifact panel remains inside the camp screen.
* Hovering `Swift Charm` on PC previews `Swift Charm`, `Owned` or `Equipped`, and `+1 movement speed`.
* Hovering `Blast Core` on PC previews `Blast Core`, `Owned` or `Equipped`, and `Basic bolts explode for 20% damage`.
* Tapping/focusing each artifact on a mobile-sized viewport previews the same text.
* Equipping and unequipping still update the equipped summary.
* Pressing Start Run hides the camp UI; active-run HUD does not expose artifact management.

- [ ] **Step 3: Update QA note**

Replace each `NOT RUN` item in `_workspace/goblin-dev/KAN-113_qa.md` with `PASS`, `FAIL`, or `BLOCKED`, and add a one-sentence note for any non-PASS item.

Expected: QA note is complete enough to paste into Jira and Confluence.

---

### Task 7: Delivery Recording

**Files:**

* Modify: `CHANGELOG.md`
* Read: `_workspace/goblin-dev/KAN-113_qa.md`
* Update Jira: `KAN-112`, `KAN-113`
* Update Confluence: V1.0 page and CHANGELOG page

- [ ] **Step 1: Add local CHANGELOG entry**

Add this entry near the top of `CHANGELOG.md`. Use the exact `PASS`, `FAIL`, or `BLOCKED` statuses recorded in `_workspace/goblin-dev/KAN-113_qa.md`:

```markdown
## 2026-07-04 - KAN-113 artifact camp panel description refinement

* Updated the existing camp artifact panel with icon-backed artifact controls and compact artifact descriptions for `Swift Charm` and `Blast Core`.
* Kept artifact management lobby/camp-only; active-run HUD does not expose inventory management.
* Used existing artifact icon asset IDs as fallback per KAN-112. Replacement icons are only needed if icon readability QA fails.
* Verification statuses match `_workspace/goblin-dev/KAN-113_qa.md`.
* Studio QA statuses match `_workspace/goblin-dev/KAN-113_qa.md` for PC/mobile panel readability, hover/tap/focus descriptions, equip, unequip, and Start Run hiding behavior.
```

Expected: CHANGELOG reflects implementation, verification, and icon decision.

- [ ] **Step 2: Add Jira result comment to `KAN-113`**

Add this Jira comment after replacing each status line with the exact value from `_workspace/goblin-dev/KAN-113_qa.md`:

```markdown
Implementation result:

* Existing camp artifact panel refined with icon-backed artifact controls.
* `Swift Charm` and `Blast Core` show description previews through PC hover and mobile tap/focus.
* Equipped/empty summary remains visible by default.
* Equip and unequip behavior remains unchanged.
* Active-run HUD does not expose artifact inventory management.

Verification:

* `rojo build default.project.json -o build\game.rbxl`: use QA note status
* `git diff --check`: use QA note status
* Studio PC QA: use QA note status
* Studio mobile-sized QA: use QA note status

Evidence: `_workspace/goblin-dev/KAN-113_qa.md`
```

Expected: Jira contains implementation and QA evidence.

- [ ] **Step 3: Add Jira result comment to `KAN-112`**

Add this Jira comment:

```markdown
Icon QA result:

Existing artifact icon asset IDs were used as fallback for `Swift Charm` and `Blast Core`.

* Swift Charm camp-panel readability: use QA note status
* Blast Core camp-panel readability: use QA note status
* Replacement production icon request needed: write `YES` only when either icon readability status is `FAIL`; otherwise write `NO`

If replacement is needed, follow the UI design output guide: 256x256 PNG, transparent background, no 9-slice, no embedded text, Roblox asset ID handoff recorded in Jira and Confluence.
```

Expected: KAN-112 is resolved as either no replacement needed or blocked by icon clarity.

- [ ] **Step 4: Update Confluence records**

Add a concise record to the V1.0 page and Confluence CHANGELOG page:

```markdown
2026-07-04 - KAN-113 artifact camp panel refinement

* Refined the existing camp artifact panel instead of adding a new inventory surface.
* Added icon-backed artifact controls and compact descriptions for `Swift Charm` and `Blast Core`.
* Kept artifact management lobby/camp-only.
* KAN-112 icon production remains QA-gated; current icon asset IDs are used unless readability QA fails.
* QA evidence: `_workspace/goblin-dev/KAN-113_qa.md`
```

Expected: Confluence source-of-truth pages reflect the scoped result.

- [ ] **Step 5: Transition tickets only after verified delivery**

If implementation, local CHANGELOG, Confluence, and Jira QA evidence are complete:

* Move `KAN-113` to `완료`.
* Move `KAN-112` to `완료` only if replacement icons are not needed or replacement icon delivery is already complete.
* If replacement icons are needed and not delivered, leave `KAN-112` non-complete and record the blocking reason.

Expected: Jira state matches delivered evidence and does not overclaim icon production.

---

### Task 8: Final Commit

**Files:**

* Commit implementation files after verification and delivery records.

- [ ] **Step 1: Review staged scope**

Run:

```powershell
git status --short
git diff -- src\client\CampController.lua CHANGELOG.md _workspace\goblin-dev\KAN-113_qa.md
```

Expected: only KAN-113/KAN-112-related implementation, changelog, and QA evidence are included. Existing unrelated dirty files remain unstaged.

- [ ] **Step 2: Stage scoped files**

Run:

```powershell
git add src\client\CampController.lua CHANGELOG.md _workspace\goblin-dev\KAN-113_qa.md
```

Expected: only the scoped files are staged.

- [ ] **Step 3: Commit**

Run:

```powershell
git commit -m "feat: refine artifact camp panel"
```

Expected: commit succeeds and includes only scoped files.
