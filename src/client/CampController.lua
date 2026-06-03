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
local runReadinessText
local campActionStatusText
local healthUpgradeText
local healthCostText
local healthProgressFill
local healthMaxBadge
local attackUpgradeText
local attackCostText
local attackProgressFill
local attackMaxBadge
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

local TEXT_LIGHT = Color3.fromRGB(247, 244, 226)
local TEXT_MUTED = Color3.fromRGB(190, 181, 150)
local TEXT_SUCCESS = Color3.fromRGB(151, 223, 143)
local TEXT_WARNING = Color3.fromRGB(238, 185, 102)

local function addTextConstraint(label, minSize, maxSize)
	label.TextScaled = true

	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MinTextSize = minSize
	constraint.MaxTextSize = maxSize
	constraint.Parent = label
end

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
	label.TextColor3 = TEXT_LIGHT
	label.TextSize = textSize
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Position = position
	label.Size = size
	label.Parent = parent
	addTextConstraint(label, 9, textSize)
	return label
end

local function createBadge(parent, name, text, position, size, color)
	local badge = Instance.new("TextLabel")
	badge.Name = name
	badge.BackgroundColor3 = color
	badge.BackgroundTransparency = 0.12
	badge.BorderSizePixel = 0
	badge.Font = Enum.Font.GothamBold
	badge.Text = text
	badge.TextColor3 = Color3.fromRGB(255, 255, 255)
	badge.TextWrapped = true
	badge.TextXAlignment = Enum.TextXAlignment.Center
	badge.TextYAlignment = Enum.TextYAlignment.Center
	badge.Position = position
	badge.Size = size
	badge.Parent = parent
	addTextConstraint(badge, 9, 14)
	return badge
end

local function createProgress(parent, name, position, size)
	local track = Instance.new("Frame")
	track.Name = name
	track.BackgroundColor3 = Color3.fromRGB(42, 34, 29)
	track.BackgroundTransparency = 0.08
	track.BorderSizePixel = 0
	track.Position = position
	track.Size = size
	track.Parent = parent

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = Color3.fromRGB(206, 142, 67)
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale(0, 1)
	fill.Parent = track

	return fill
end

local function createImageButton(parent, name, image, position, size, text, maxTextSize)
	local button = Instance.new("ImageButton")
	button.Name = name
	button.BackgroundTransparency = 1
	button.Image = image
	button.Position = position
	button.Size = size
	button.ScaleType = Enum.ScaleType.Stretch
	button.AutoButtonColor = false
	button.Parent = parent

	local label = createText(button, "Label", text, UDim2.fromScale(0.08, 0.16), UDim2.fromScale(0.84, 0.68), maxTextSize or 18)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center

	return button
end

local function setButtonText(button, text)
	local label = button and button:FindFirstChild("Label")
	if label and label:IsA("TextLabel") then
		label.Text = text
	end
end

local function setSecondaryButtonEnabled(button, enabled, enabledText, disabledText)
	if not button then
		return
	end

	button.Active = enabled
	button.Image = enabled and campAssets.camp_button_secondary_default_512x128 or campAssets.camp_button_secondary_disabled_512x128
	setButtonText(button, enabled and enabledText or disabledText)
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
		setButtonText(button, "Equipped")
	elseif ownsArtifact(progression, artifactId) then
		button.Image = campAssets.camp_button_secondary_default_512x128
		setButtonText(button, ArtifactDefinitions[artifactId].DisplayName)
	else
		button.Image = campAssets.camp_button_secondary_disabled_512x128
		setButtonText(button, "Locked")
	end
end

local function updateUpgradeCard(upgradeId, level, cost, resourceAmount, textLabel, costLabel, progressFill, button, maxBadge)
	local definition = PersistentUpgradeDefinitions[upgradeId]
	local maxLevel = definition.MaxLevel
	local displayName = upgradeId == "MaxHealth" and "Max Health" or "Attack"
	local ratio = maxLevel > 0 and math.clamp(level / maxLevel, 0, 1) or 0

	textLabel.Text = string.format("%s\nLv %d / %d", displayName, level, maxLevel)
	progressFill.Size = UDim2.fromScale(ratio, 1)

	if cost then
		local canBuy = resourceAmount >= cost
		costLabel.Text = string.format("Cost %d Growth Stones", cost)
		costLabel.TextColor3 = canBuy and TEXT_LIGHT or TEXT_WARNING
		button.Visible = true
		maxBadge.Visible = false
		setSecondaryButtonEnabled(button, canBuy, "Buy", "Need Stones")
	else
		costLabel.Text = "Complete - 100%"
		costLabel.TextColor3 = TEXT_SUCCESS
		button.Visible = false
		maxBadge.Visible = true
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

	resourcesText.Text = string.format("Growth Stones  %d\nCamp Materials  %d", growthStones, campMaterials)
	campLevelText.Text = string.format("Camp Level %d / %d", campLevel, CampConfig.MaxLevel)
	if appearanceText then
		appearanceText.Text = string.format(
			"Goblin Level %d\n%s",
			appearanceStage.Level or appearanceStage.Stage or 0,
			appearanceStage.DisplayName or "Sprout Goblin"
		)
	end
	if appearanceBadge and type(appearanceStage.BadgeAssetId) == "string" then
		appearanceBadge.Image = appearanceStage.BadgeAssetId
	end

	updateUpgradeCard("MaxHealth", healthLevel, healthCost, growthStones, healthUpgradeText, healthCostText, healthProgressFill, healthButton, healthMaxBadge)
	updateUpgradeCard("AttackDamage", attackLevel, attackCost, growthStones, attackUpgradeText, attackCostText, attackProgressFill, attackButton, attackMaxBadge)

	artifactText.Text = string.format("Equipped Artifact\n%s", getArtifactDisplayName(progression.EquippedArtifactId))
	if artifactSlotImage then
		artifactSlotImage.Image = progression.EquippedArtifactId and campAssets.camp_slot_artifact_equipped_256x256 or campAssets.camp_slot_artifact_empty_256x256
	end
	setArtifactButtonState(swiftArtifactButton, "SwiftCharm", progression)
	setArtifactButtonState(blastArtifactButton, "BlastCore", progression)
	if unequipArtifactButton then
		local canUnequip = progression.EquippedArtifactId ~= nil
		setSecondaryButtonEnabled(unequipArtifactButton, canUnequip, "Unequip", "No Artifact")
	end

	if campCost then
		local canUpgradeCamp = campMaterials >= campCost
		campActionStatusText.Text = string.format("Next camp upgrade costs %d materials.", campCost)
		campActionStatusText.TextColor3 = canUpgradeCamp and TEXT_LIGHT or TEXT_WARNING
		setSecondaryButtonEnabled(campButton, canUpgradeCamp, "Upgrade Camp", "Need Materials")
	else
		campActionStatusText.Text = "Camp is fully upgraded."
		campActionStatusText.TextColor3 = TEXT_SUCCESS
		setSecondaryButtonEnabled(campButton, false, "Upgrade Camp", "Max Camp")
	end

	runReadinessText.Text = "Ready for your next run.\nSpend available upgrades first, then start."
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

	local panel = createImage(root, "MainBoard", campAssets.camp_panel_main_default_768x512, UDim2.fromScale(0.045, 0.055), UDim2.fromScale(0.63, 0.88))
	createText(panel, "Title", "Goblin Camp", UDim2.fromScale(0.08, 0.085), UDim2.fromScale(0.34, 0.07), 26)

	appearanceBadge = createImage(panel, "GrowthLevelBadge", campAssets.badge_goblin_growth_0_256x256, UDim2.fromScale(0.82, 0.07), UDim2.fromScale(0.09, 0.12))
	appearanceText = createText(panel, "GrowthLevelText", "", UDim2.fromScale(0.55, 0.075), UDim2.fromScale(0.24, 0.1), 13)
	appearanceText.TextXAlignment = Enum.TextXAlignment.Right

	local infoBoard = Instance.new("Frame")
	infoBoard.Name = "TopInfoBoard"
	infoBoard.BackgroundColor3 = Color3.fromRGB(35, 28, 24)
	infoBoard.BackgroundTransparency = 0.2
	infoBoard.BorderSizePixel = 0
	infoBoard.Position = UDim2.fromScale(0.08, 0.19)
	infoBoard.Size = UDim2.fromScale(0.84, 0.13)
	infoBoard.Parent = panel

	createImage(infoBoard, "GrowthStoneIcon", campAssets.icon_growth_stone_default_256x256, UDim2.fromScale(0.04, 0.18), UDim2.fromScale(0.08, 0.56))
	createImage(infoBoard, "CampMaterialIcon", campAssets.icon_camp_material_default_256x256, UDim2.fromScale(0.33, 0.18), UDim2.fromScale(0.08, 0.56))
	resourcesText = createText(infoBoard, "Resources", "", UDim2.fromScale(0.13, 0.12), UDim2.fromScale(0.38, 0.76), 14)
	campLevelText = createText(infoBoard, "CampLevel", "", UDim2.fromScale(0.56, 0.18), UDim2.fromScale(0.35, 0.6), 15)
	campLevelText.TextXAlignment = Enum.TextXAlignment.Right

	local healthCard = createImage(panel, "HealthCard", campAssets.camp_card_upgrade_default_512x256, UDim2.fromScale(0.08, 0.37), UDim2.fromScale(0.4, 0.22))
	createImage(healthCard, "Icon", campAssets.icon_upgrade_health_default_256x256, UDim2.fromScale(0.06, 0.18), UDim2.fromScale(0.16, 0.44))
	healthUpgradeText = createText(healthCard, "Title", "", UDim2.fromScale(0.26, 0.12), UDim2.fromScale(0.52, 0.3), 14)
	healthCostText = createText(healthCard, "Status", "", UDim2.fromScale(0.26, 0.43), UDim2.fromScale(0.62, 0.18), 11)
	healthProgressFill = createProgress(healthCard, "Progress", UDim2.fromScale(0.26, 0.66), UDim2.fromScale(0.52, 0.08))
	healthButton = createImageButton(healthCard, "BuyHealth", campAssets.camp_button_secondary_default_512x128, UDim2.fromScale(0.29, 0.76), UDim2.fromScale(0.46, 0.18), "Buy", 14)
	healthMaxBadge = createBadge(healthCard, "MaxBadge", "MAX", UDim2.fromScale(0.78, 0.62), UDim2.fromScale(0.16, 0.22), Color3.fromRGB(75, 125, 69))
	healthMaxBadge.Visible = false
	healthButton.Activated:Connect(function()
		if healthButton.Visible and healthButton.Active then
			Remotes.get(Remotes.Names.PurchasePersistentUpgrade):FireServer("MaxHealth")
		end
	end)

	local attackCard = createImage(panel, "AttackCard", campAssets.camp_card_upgrade_default_512x256, UDim2.fromScale(0.52, 0.37), UDim2.fromScale(0.4, 0.22))
	createImage(attackCard, "Icon", campAssets.icon_upgrade_attack_default_256x256, UDim2.fromScale(0.06, 0.18), UDim2.fromScale(0.16, 0.44))
	attackUpgradeText = createText(attackCard, "Title", "", UDim2.fromScale(0.26, 0.12), UDim2.fromScale(0.52, 0.3), 14)
	attackCostText = createText(attackCard, "Status", "", UDim2.fromScale(0.26, 0.43), UDim2.fromScale(0.62, 0.18), 11)
	attackProgressFill = createProgress(attackCard, "Progress", UDim2.fromScale(0.26, 0.66), UDim2.fromScale(0.52, 0.08))
	attackButton = createImageButton(attackCard, "BuyAttack", campAssets.camp_button_secondary_default_512x128, UDim2.fromScale(0.29, 0.76), UDim2.fromScale(0.46, 0.18), "Buy", 14)
	attackMaxBadge = createBadge(attackCard, "MaxBadge", "MAX", UDim2.fromScale(0.78, 0.62), UDim2.fromScale(0.16, 0.22), Color3.fromRGB(75, 125, 69))
	attackMaxBadge.Visible = false
	attackButton.Activated:Connect(function()
		if attackButton.Visible and attackButton.Active then
			Remotes.get(Remotes.Names.PurchasePersistentUpgrade):FireServer("AttackDamage")
		end
	end)

	local artifactCard = createImage(panel, "ArtifactBoard", campAssets.camp_card_artifact_default_512x256, UDim2.fromScale(0.08, 0.64), UDim2.fromScale(0.84, 0.21))
	artifactSlotImage = createImage(artifactCard, "Slot", campAssets.camp_slot_artifact_empty_256x256, UDim2.fromScale(0.05, 0.17), UDim2.fromScale(0.11, 0.5))
	artifactText = createText(artifactCard, "Text", "", UDim2.fromScale(0.19, 0.14), UDim2.fromScale(0.28, 0.52), 13)
	swiftArtifactButton = createImageButton(artifactCard, "EquipSwiftCharm", campAssets.camp_button_secondary_default_512x128, UDim2.fromScale(0.48, 0.21), UDim2.fromScale(0.18, 0.28), "Swift", 12)
	blastArtifactButton = createImageButton(artifactCard, "EquipBlastCore", campAssets.camp_button_secondary_default_512x128, UDim2.fromScale(0.68, 0.21), UDim2.fromScale(0.18, 0.28), "Blast", 12)
	unequipArtifactButton = createImageButton(artifactCard, "UnequipArtifact", campAssets.camp_button_secondary_default_512x128, UDim2.fromScale(0.56, 0.57), UDim2.fromScale(0.26, 0.25), "Unequip", 12)
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
	unequipArtifactButton.Activated:Connect(function()
		if unequipArtifactButton.Active and latestProgression and latestProgression.EquippedArtifactId then
			Remotes.get(Remotes.Names.UnequipArtifact):FireServer()
		end
	end)

	local actionPanel = createImage(root, "RunBoard", campAssets.camp_panel_result_default_768x384, UDim2.fromScale(0.69, 0.18), UDim2.fromScale(0.27, 0.56))
	createText(actionPanel, "Title", "Next Run", UDim2.fromScale(0.12, 0.15), UDim2.fromScale(0.72, 0.09), 22)
	runReadinessText = createText(actionPanel, "Readiness", "", UDim2.fromScale(0.12, 0.27), UDim2.fromScale(0.76, 0.17), 14)
	campActionStatusText = createText(actionPanel, "CampStatus", "", UDim2.fromScale(0.12, 0.48), UDim2.fromScale(0.76, 0.12), 13)

	campButton = createImageButton(actionPanel, "CampLevelBuy", campAssets.camp_button_secondary_default_512x128, UDim2.fromScale(0.18, 0.61), UDim2.fromScale(0.64, 0.12), "Upgrade Camp", 16)
	campButton.Activated:Connect(function()
		if campButton.Active then
			Remotes.get(Remotes.Names.PurchaseCampLevel):FireServer()
		end
	end)

	local startButton = createImageButton(actionPanel, "StartRun", campAssets.camp_button_primary_default_512x128, UDim2.fromScale(0.13, 0.78), UDim2.fromScale(0.74, 0.15), "Start Run", 21)
	startButton.Activated:Connect(function()
		Remotes.get(Remotes.Names.StartRun):FireServer()
		hideCamp()
	end)

	if RunService:IsStudio() then
		local resetProgressionButton = createImageButton(root, "ResetProgression", campAssets.camp_button_secondary_default_512x128, UDim2.fromScale(0.72, 0.78), UDim2.fromScale(0.21, 0.055), "Reset QA", 14)
		resetProgressionButton.Activated:Connect(function()
			Remotes.get(Remotes.Names.ResetMetaProgression):FireServer()
		end)
	end
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
