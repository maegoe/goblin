local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ArtifactDefinitions = require(Shared:WaitForChild("ArtifactDefinitions"))
local Assets = require(Shared:WaitForChild("Assets"))
local CampConfig = require(Shared:WaitForChild("CampConfig"))
local PersistentUpgradeDefinitions = require(Shared:WaitForChild("PersistentUpgradeDefinitions"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local CampController = {}

local localPlayer = Players.LocalPlayer
local campAssets = Assets.v0_4.camp_ui
local gui
local root
local resourcesText
local campLevelText
local healthUpgradeText
local attackUpgradeText
local artifactText
local artifactSlotImage
local appearanceBadge
local appearanceText
local campButton
local healthButton
local attackButton
local swiftArtifactButton
local blastArtifactButton
local unequipArtifactButton
local latestProgression = nil
local latestAppearanceStage = nil

local function createImage(parent, name, image, position, size)
	local item = Instance.new("ImageLabel")
	item.Name = name
	item.BackgroundTransparency = 1
	item.Image = image
	item.Position = position
	item.Size = size
	item.ScaleType = Enum.ScaleType.Stretch
	item.Parent = parent
	return item
end

local function createText(parent, name, text, position, size, textSize)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = Color3.fromRGB(247, 244, 226)
	label.TextSize = textSize
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Position = position
	label.Size = size
	label.Parent = parent
	return label
end

local function createImageButton(parent, name, image, position, size, text)
	local button = Instance.new("ImageButton")
	button.Name = name
	button.BackgroundTransparency = 1
	button.Image = image
	button.Position = position
	button.Size = size
	button.ScaleType = Enum.ScaleType.Stretch
	button.Parent = parent

	local label = createText(button, "Label", text, UDim2.fromScale(0.08, 0.16), UDim2.fromScale(0.84, 0.68), 18)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextScaled = true

	local sizeConstraint = Instance.new("UITextSizeConstraint")
	sizeConstraint.MaxTextSize = 18
	sizeConstraint.MinTextSize = 10
	sizeConstraint.Parent = label

	return button
end

local function getUpgradeLevel(progression, upgradeId)
	local upgrades = progression and progression.PersistentUpgrades
	if type(upgrades) ~= "table" or type(upgrades[upgradeId]) ~= "number" then
		return 0
	end

	return math.max(0, math.floor(upgrades[upgradeId]))
end

local function getNextUpgradeCost(progression, upgradeId)
	local definition = PersistentUpgradeDefinitions[upgradeId]
	local level = getUpgradeLevel(progression, upgradeId)
	if not definition or level >= definition.MaxLevel then
		return nil
	end

	return definition.Costs[level + 1]
end

local function getNextCampCost(progression)
	local level = math.max(0, math.floor((progression and progression.CampLevel) or 0))
	if level >= CampConfig.MaxLevel then
		return nil
	end

	return CampConfig.LevelCosts[level + 1]
end

local function ownsArtifact(progression, artifactId)
	local ownedArtifacts = progression and progression.OwnedArtifacts
	if type(ownedArtifacts) ~= "table" then
		return false
	end

	for _, ownedArtifactId in ipairs(ownedArtifacts) do
		if ownedArtifactId == artifactId then
			return true
		end
	end

	return false
end

local function getArtifactDisplayName(artifactId)
	local definition = ArtifactDefinitions[artifactId]
	if definition then
		return definition.DisplayName
	end

	return "Empty"
end

local function setArtifactButtonState(button, artifactId, progression)
	if not button then
		return
	end

	local equippedArtifactId = progression and progression.EquippedArtifactId
	if equippedArtifactId == artifactId then
		button.Image = campAssets.camp_button_secondary_pressed_512x128
	elseif ownsArtifact(progression, artifactId) then
		button.Image = campAssets.camp_button_secondary_default_512x128
	else
		button.Image = campAssets.camp_button_secondary_disabled_512x128
	end
end

local function updateCamp()
	local progression = latestProgression or {}
	local appearanceStage = latestAppearanceStage or {}
	local growthStones = progression.GrowthStones or 0
	local campMaterials = progression.CampMaterials or 0
	local campLevel = progression.CampLevel or 0
	local healthLevel = getUpgradeLevel(progression, "MaxHealth")
	local attackLevel = getUpgradeLevel(progression, "AttackDamage")
	local healthCost = getNextUpgradeCost(progression, "MaxHealth")
	local attackCost = getNextUpgradeCost(progression, "AttackDamage")
	local campCost = getNextCampCost(progression)

	resourcesText.Text = string.format("Growth Stones %d    Camp Materials %d", growthStones, campMaterials)
	campLevelText.Text = string.format("Camp Level %d / %d%s", campLevel, CampConfig.MaxLevel, campCost and ("    Next " .. campCost) or "    Max")
	healthUpgradeText.Text = string.format("Max Health Lv %d / 5%s", healthLevel, healthCost and ("    Cost " .. healthCost) or "    Max")
	attackUpgradeText.Text = string.format("Attack Lv %d / 5%s", attackLevel, attackCost and ("    Cost " .. attackCost) or "    Max")
	artifactText.Text = string.format("Artifact: %s", getArtifactDisplayName(progression.EquippedArtifactId))
	if artifactSlotImage then
		artifactSlotImage.Image = progression.EquippedArtifactId and campAssets.camp_slot_artifact_equipped_256x256 or campAssets.camp_slot_artifact_empty_256x256
	end
	if appearanceText then
		appearanceText.Text = string.format(
			"Goblin Level %d    %s",
			appearanceStage.Level or appearanceStage.Stage or 0,
			appearanceStage.DisplayName or "Sprout Goblin"
		)
	end
	if appearanceBadge and type(appearanceStage.BadgeAssetId) == "string" then
		appearanceBadge.Image = appearanceStage.BadgeAssetId
	end

	if campButton then
		campButton.Image = campCost and campMaterials >= campCost and campAssets.camp_button_secondary_default_512x128 or campAssets.camp_button_secondary_disabled_512x128
	end
	if healthButton then
		healthButton.Image = healthCost and growthStones >= healthCost and campAssets.camp_button_secondary_default_512x128 or campAssets.camp_button_secondary_disabled_512x128
	end
	if attackButton then
		attackButton.Image = attackCost and growthStones >= attackCost and campAssets.camp_button_secondary_default_512x128 or campAssets.camp_button_secondary_disabled_512x128
	end
	setArtifactButtonState(swiftArtifactButton, "SwiftCharm", progression)
	setArtifactButtonState(blastArtifactButton, "BlastCore", progression)
	if unequipArtifactButton then
		unequipArtifactButton.Image = progression.EquippedArtifactId and campAssets.camp_button_secondary_default_512x128 or campAssets.camp_button_secondary_disabled_512x128
	end
end

local function setOtherUiVisible(hudVisible, hideResult)
	local playerGui = localPlayer:FindFirstChild("PlayerGui")
	if not playerGui then
		return
	end

	local hud = playerGui:FindFirstChild("GoblinHud")
	if hud then
		hud.Enabled = hudVisible
	end

	local result = playerGui:FindFirstChild("GoblinRunResult")
	if result and hideResult then
		result.Enabled = false
	end
end

local function showCamp(keepResultVisible)
	if gui then
		gui.Enabled = true
	end
	setOtherUiVisible(false, keepResultVisible ~= true)
end

local function hideCamp()
	if gui then
		gui.Enabled = false
	end
	setOtherUiVisible(true, true)
end

local function buildCamp()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	gui = Instance.new("ScreenGui")
	gui.Name = "GoblinCamp"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = playerGui

	root = Instance.new("Frame")
	root.Name = "Root"
	root.BackgroundColor3 = Color3.fromRGB(10, 12, 14)
	root.BorderSizePixel = 0
	root.Size = UDim2.fromScale(1, 1)
	root.Parent = gui

	local background = createImage(root, "Background", campAssets.camp_hub_background_default_960x720, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1))
	background.ScaleType = Enum.ScaleType.Crop

	local panel = createImage(root, "MainPanel", campAssets.camp_panel_main_default_768x512, UDim2.fromScale(0.055, 0.08), UDim2.fromScale(0.59, 0.79))
	createText(panel, "Title", "Goblin Camp", UDim2.fromScale(0.09, 0.105), UDim2.fromScale(0.42, 0.07), 26)
	appearanceBadge = createImage(panel, "GrowthLevelBadge", campAssets.badge_goblin_growth_0_256x256, UDim2.fromScale(0.83, 0.09), UDim2.fromScale(0.08, 0.115))
	appearanceText = createText(panel, "GrowthLevelText", "", UDim2.fromScale(0.55, 0.115), UDim2.fromScale(0.25, 0.06), 13)
	appearanceText.TextXAlignment = Enum.TextXAlignment.Right
	createImage(panel, "GrowthStoneIcon", campAssets.icon_growth_stone_default_256x256, UDim2.fromScale(0.125, 0.22), UDim2.fromScale(0.035, 0.055))
	createImage(panel, "CampMaterialIcon", campAssets.icon_camp_material_default_256x256, UDim2.fromScale(0.365, 0.22), UDim2.fromScale(0.035, 0.055))
	resourcesText = createText(panel, "Resources", "", UDim2.fromScale(0.17, 0.222), UDim2.fromScale(0.58, 0.06), 14)
	campLevelText = createText(panel, "CampLevel", "", UDim2.fromScale(0.125, 0.31), UDim2.fromScale(0.6, 0.06), 14)

	local healthCard = createImage(panel, "HealthCard", campAssets.camp_card_upgrade_default_512x256, UDim2.fromScale(0.105, 0.405), UDim2.fromScale(0.38, 0.215))
	createImage(healthCard, "Icon", campAssets.icon_upgrade_health_default_256x256, UDim2.fromScale(0.07, 0.2), UDim2.fromScale(0.15, 0.45))
	healthUpgradeText = createText(healthCard, "Text", "", UDim2.fromScale(0.27, 0.22), UDim2.fromScale(0.62, 0.22), 13)

	local attackCard = createImage(panel, "AttackCard", campAssets.camp_card_upgrade_default_512x256, UDim2.fromScale(0.515, 0.405), UDim2.fromScale(0.38, 0.215))
	createImage(attackCard, "Icon", campAssets.icon_upgrade_attack_default_256x256, UDim2.fromScale(0.07, 0.2), UDim2.fromScale(0.15, 0.45))
	attackUpgradeText = createText(attackCard, "Text", "", UDim2.fromScale(0.27, 0.22), UDim2.fromScale(0.62, 0.22), 13)

	local artifactCard = createImage(panel, "ArtifactCard", campAssets.camp_card_artifact_default_512x256, UDim2.fromScale(0.305, 0.595), UDim2.fromScale(0.39, 0.19))
	artifactSlotImage = createImage(artifactCard, "Slot", campAssets.camp_slot_artifact_empty_256x256, UDim2.fromScale(0.075, 0.17), UDim2.fromScale(0.15, 0.47))
	artifactText = createText(artifactCard, "Text", "", UDim2.fromScale(0.28, 0.13), UDim2.fromScale(0.6, 0.2), 11)
	createImage(artifactCard, "SwiftIcon", campAssets.icon_artifact_swift_charm_default_256x256, UDim2.fromScale(0.31, 0.39), UDim2.fromScale(0.075, 0.23))
	createImage(artifactCard, "BlastIcon", campAssets.icon_artifact_blast_core_default_256x256, UDim2.fromScale(0.61, 0.39), UDim2.fromScale(0.075, 0.23))

	local startButton = createImageButton(root, "StartRun", campAssets.camp_button_primary_default_512x128, UDim2.fromScale(0.69, 0.72), UDim2.fromScale(0.24, 0.1), "Start Run")
	startButton.Activated:Connect(function()
		Remotes.get(Remotes.Names.StartRun):FireServer()
		hideCamp()
	end)

	campButton = createImageButton(root, "CampLevelBuy", campAssets.camp_button_secondary_default_512x128, UDim2.fromScale(0.69, 0.58), UDim2.fromScale(0.24, 0.08), "Upgrade Camp")
	campButton.Activated:Connect(function()
		Remotes.get(Remotes.Names.PurchaseCampLevel):FireServer()
	end)

	if RunService:IsStudio() then
		local resetProgressionButton = createImageButton(root, "ResetProgression", campAssets.camp_button_secondary_default_512x128, UDim2.fromScale(0.69, 0.84), UDim2.fromScale(0.24, 0.06), "Reset QA")
		resetProgressionButton.Activated:Connect(function()
			Remotes.get(Remotes.Names.ResetMetaProgression):FireServer()
		end)
	end

	healthButton = createImageButton(healthCard, "BuyHealth", campAssets.camp_button_secondary_default_512x128, UDim2.fromScale(0.3, 0.56), UDim2.fromScale(0.54, 0.25), "Buy")
	healthButton.Activated:Connect(function()
		Remotes.get(Remotes.Names.PurchasePersistentUpgrade):FireServer("MaxHealth")
	end)

	attackButton = createImageButton(attackCard, "BuyAttack", campAssets.camp_button_secondary_default_512x128, UDim2.fromScale(0.3, 0.56), UDim2.fromScale(0.54, 0.25), "Buy")
	attackButton.Activated:Connect(function()
		Remotes.get(Remotes.Names.PurchasePersistentUpgrade):FireServer("AttackDamage")
	end)

	swiftArtifactButton = createImageButton(artifactCard, "EquipSwiftCharm", campAssets.camp_button_secondary_default_512x128, UDim2.fromScale(0.39, 0.39), UDim2.fromScale(0.18, 0.23), "Swift")
	swiftArtifactButton.Activated:Connect(function()
		if ownsArtifact(latestProgression, "SwiftCharm") then
			Remotes.get(Remotes.Names.EquipArtifact):FireServer("SwiftCharm")
		end
	end)

	blastArtifactButton = createImageButton(artifactCard, "EquipBlastCore", campAssets.camp_button_secondary_default_512x128, UDim2.fromScale(0.69, 0.39), UDim2.fromScale(0.18, 0.23), "Blast")
	blastArtifactButton.Activated:Connect(function()
		if ownsArtifact(latestProgression, "BlastCore") then
			Remotes.get(Remotes.Names.EquipArtifact):FireServer("BlastCore")
		end
	end)

	unequipArtifactButton = createImageButton(artifactCard, "UnequipArtifact", campAssets.camp_button_secondary_default_512x128, UDim2.fromScale(0.31, 0.66), UDim2.fromScale(0.52, 0.23), "Unequip")
	unequipArtifactButton.Activated:Connect(function()
		if latestProgression and latestProgression.EquippedArtifactId then
			Remotes.get(Remotes.Names.UnequipArtifact):FireServer()
		end
	end)
end

function CampController.start()
	buildCamp()
	Remotes.get(Remotes.Names.MetaProgressionChanged).OnClientEvent:Connect(function(payload)
		if type(payload) == "table" then
			latestProgression = payload.snapshot
			latestAppearanceStage = payload.appearanceStage
			updateCamp()
		end
	end)
	Remotes.get(Remotes.Names.RunEnded).OnClientEvent:Connect(function()
		showCamp(true)
	end)

	local ok, payload = pcall(function()
		return Remotes.get(Remotes.FunctionNames.GetMetaProgressionSnapshot):InvokeServer()
	end)
	if ok and type(payload) == "table" then
		latestProgression = payload.snapshot
		latestAppearanceStage = payload.appearanceStage
	end
	updateCamp()
	showCamp(false)
end

return CampController
