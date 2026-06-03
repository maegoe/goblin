local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = require(Shared:WaitForChild("Assets"))
local FeedbackEvents = require(Shared:WaitForChild("FeedbackEvents"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local Client = script.Parent
local FeedbackAudioController = require(Client:WaitForChild("FeedbackAudioController"))

local LevelUpController = {}

local localPlayer = Players.LocalPlayer
local overlay
local titleLabel
local choicesFrame
local choicesSizeConstraint
local choicesLayout
local buttons = {}
local buttonConnections = {}

local ICON_BY_UPGRADE_ID = {
	AttackDamageUp = "ATK",
	AttackSpeedUp = "SPD",
	MoveSpeedUp = "MOV",
	RewardBoost = "RWD",
	MaxHealthUp = "HP",
	QuickRecovery = "HEAL",
	ExplosiveBolt = "AOE",
}

local ICON_ASSET_KEY_BY_UPGRADE_ID = {
	AttackDamageUp = "icon_growth_attack_128x128",
	AttackSpeedUp = "icon_growth_attack_128x128",
	MoveSpeedUp = "icon_growth_speed_128x128",
	RewardBoost = "icon_growth_reward_128x128",
	MaxHealthUp = "icon_growth_heal_128x128",
	QuickRecovery = "icon_growth_heal_128x128",
	ExplosiveBolt = "icon_growth_attack_128x128",
}

local function toColor3(color)
	if typeof(color) == "table" then
		return Color3.fromRGB(color[1] or 255, color[2] or 255, color[3] or 255)
	end

	return Color3.fromRGB(255, 255, 255)
end

local function getChoiceIconText(choice)
	if not choice then
		return "UP"
	end

	return ICON_BY_UPGRADE_ID[choice.id] or "UP"
end

local function getChoiceIconAsset(choice)
	local growthIcons = Assets.v1_0 and Assets.v1_0.growth_icons
	local assetKey = choice and ICON_ASSET_KEY_BY_UPGRADE_ID[choice.id]

	return growthIcons and assetKey and growthIcons[assetKey] or nil
end

local function addTextSizeConstraint(label, minSize, maxSize)
	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MinTextSize = minSize
	constraint.MaxTextSize = maxSize
	constraint.Parent = label
	return constraint
end

local function useVerticalChoices()
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1024, 768)

	return viewport.X < 700 or viewport.Y > viewport.X
end

local function applyChoiceLayout()
	if not choicesFrame or not choicesLayout or not choicesSizeConstraint then
		return
	end

	if useVerticalChoices() then
		if titleLabel then
			titleLabel.Position = UDim2.fromScale(0.5, 0.12)
		end

		choicesFrame.Size = UDim2.fromScale(0.86, 0.58)
		choicesFrame.Position = UDim2.fromScale(0.5, 0.26)
		choicesSizeConstraint.MinSize = Vector2.new(260, 300)
		choicesSizeConstraint.MaxSize = Vector2.new(430, 460)
		choicesLayout.FillDirection = Enum.FillDirection.Vertical

		for _, button in ipairs(buttons) do
			button.Size = UDim2.new(1, 0, 0.31, -8)
			local icon = button:FindFirstChild("Icon")
			if icon then
				icon.Size = UDim2.fromScale(0.22, 0.56)
				icon.Position = UDim2.fromScale(0.06, 0.16)
			end
		end
	else
		if titleLabel then
			titleLabel.Position = UDim2.fromScale(0.5, 0.2)
		end

		choicesFrame.Size = UDim2.fromScale(0.9, 0.3)
		choicesFrame.Position = UDim2.fromScale(0.5, 0.36)
		choicesSizeConstraint.MinSize = Vector2.new(300, 148)
		choicesSizeConstraint.MaxSize = Vector2.new(920, 220)
		choicesLayout.FillDirection = Enum.FillDirection.Horizontal

		for _, button in ipairs(buttons) do
			button.Size = UDim2.new(0.32, -8, 1, 0)
			local icon = button:FindFirstChild("Icon")
			if icon then
				icon.Size = UDim2.fromScale(0.32, 0.32)
				icon.Position = UDim2.fromScale(0.08, 0.12)
			end
		end
	end
end

local function createButton(parent, index)
	local button = Instance.new("TextButton")
	button.Name = "Choice" .. index
	button.BackgroundColor3 = Color3.fromRGB(35, 40, 48)
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Text = ""
	button.Size = UDim2.new(0.32, -8, 1, 0)
	button.LayoutOrder = index
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(94, 104, 124)
	stroke.Thickness = 2
	stroke.Transparency = 0.15
	stroke.Parent = button

	local icon = Instance.new("Frame")
	icon.Name = "Icon"
	icon.BackgroundColor3 = Color3.fromRGB(22, 26, 32)
	icon.BorderSizePixel = 0
	icon.Size = UDim2.fromScale(0.32, 0.32)
	icon.Position = UDim2.fromScale(0.08, 0.12)
	icon.Parent = button

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 8)
	iconCorner.Parent = icon

	local iconAspect = Instance.new("UIAspectRatioConstraint")
	iconAspect.AspectRatio = 1
	iconAspect.DominantAxis = Enum.DominantAxis.Width
	iconAspect.Parent = icon

	local iconStroke = Instance.new("UIStroke")
	iconStroke.Name = "RarityStroke"
	iconStroke.Color = Color3.fromRGB(94, 104, 124)
	iconStroke.Thickness = 2
	iconStroke.Transparency = 0.05
	iconStroke.Parent = icon

	local iconImage = Instance.new("ImageLabel")
	iconImage.Name = "IconImage"
	iconImage.BackgroundTransparency = 1
	iconImage.Image = ""
	iconImage.ScaleType = Enum.ScaleType.Fit
	iconImage.Size = UDim2.fromScale(0.82, 0.82)
	iconImage.Position = UDim2.fromScale(0.5, 0.5)
	iconImage.AnchorPoint = Vector2.new(0.5, 0.5)
	iconImage.Visible = false
	iconImage.Parent = icon

	local iconText = Instance.new("TextLabel")
	iconText.Name = "IconText"
	iconText.BackgroundTransparency = 1
	iconText.Font = Enum.Font.GothamBlack
	iconText.Text = "UP"
	iconText.TextColor3 = Color3.fromRGB(255, 255, 255)
	iconText.TextScaled = true
	iconText.Size = UDim2.fromScale(0.82, 0.82)
	iconText.Position = UDim2.fromScale(0.5, 0.5)
	iconText.AnchorPoint = Vector2.new(0.5, 0.5)
	iconText.Parent = icon
	addTextSizeConstraint(iconText, 10, 28)

	local rarity = Instance.new("TextLabel")
	rarity.Name = "Rarity"
	rarity.BackgroundTransparency = 1
	rarity.Font = Enum.Font.GothamBold
	rarity.Text = "Common"
	rarity.TextColor3 = Color3.fromRGB(190, 198, 210)
	rarity.TextScaled = true
	rarity.TextXAlignment = Enum.TextXAlignment.Left
	rarity.Size = UDim2.fromScale(0.52, 0.16)
	rarity.Position = UDim2.fromScale(0.4, 0.12)
	rarity.Parent = button

	local name = Instance.new("TextLabel")
	name.Name = "ChoiceName"
	name.BackgroundTransparency = 1
	name.Font = Enum.Font.GothamBlack
	name.Text = ""
	name.TextColor3 = Color3.fromRGB(255, 255, 255)
	name.TextScaled = true
	name.TextWrapped = true
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.TextYAlignment = Enum.TextYAlignment.Center
	name.Size = UDim2.fromScale(0.52, 0.28)
	name.Position = UDim2.fromScale(0.4, 0.29)
	name.Parent = button

	local description = Instance.new("TextLabel")
	description.Name = "Description"
	description.BackgroundTransparency = 1
	description.Font = Enum.Font.GothamMedium
	description.Text = ""
	description.TextColor3 = Color3.fromRGB(224, 230, 238)
	description.TextScaled = true
	description.TextWrapped = true
	description.TextXAlignment = Enum.TextXAlignment.Left
	description.TextYAlignment = Enum.TextYAlignment.Top
	description.Size = UDim2.fromScale(0.84, 0.26)
	description.Position = UDim2.fromScale(0.08, 0.63)
	description.Parent = button

	return button
end

local function setChoiceButton(button, choice)
	local rarityColor = toColor3(choice.rarityColor)
	local icon = button:FindFirstChild("Icon")
	local rarity = button:FindFirstChild("Rarity")
	local name = button:FindFirstChild("ChoiceName")
	local description = button:FindFirstChild("Description")

	if icon then
		local iconStroke = icon:FindFirstChild("RarityStroke")
		local iconAsset = getChoiceIconAsset(choice)
		local iconImage = icon:FindFirstChild("IconImage")
		local iconText = icon:FindFirstChild("IconText")

		if iconStroke and iconStroke:IsA("UIStroke") then
			iconStroke.Color = rarityColor
		end
		if iconImage then
			iconImage.Image = iconAsset or ""
			iconImage.Visible = iconAsset ~= nil
		end
		if iconText then
			iconText.Text = getChoiceIconText(choice)
			iconText.TextColor3 = rarityColor
			iconText.Visible = iconAsset == nil
		end
	end
	if rarity then
		rarity.Text = choice.rarityLabel
		rarity.TextColor3 = rarityColor
	end
	if name then
		name.Text = choice.displayName
	end
	if description then
		description.Text = choice.description
	end
end

local function buildUi()
	local playerGui = localPlayer:WaitForChild("PlayerGui")

	overlay = Instance.new("ScreenGui")
	overlay.Name = "LevelUpChoices"
	overlay.ResetOnSpawn = false
	overlay.IgnoreGuiInset = true
	overlay.Enabled = false
	overlay.Parent = playerGui

	local shade = Instance.new("Frame")
	shade.Name = "Shade"
	shade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shade.BackgroundTransparency = 0.35
	shade.BorderSizePixel = 0
	shade.Size = UDim2.fromScale(1, 1)
	shade.Parent = overlay

	titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.Text = "Level Up"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextScaled = true
	titleLabel.Size = UDim2.fromOffset(320, 56)
	titleLabel.Position = UDim2.fromScale(0.5, 0.2)
	titleLabel.AnchorPoint = Vector2.new(0.5, 0)
	titleLabel.Parent = overlay

	choicesFrame = Instance.new("Frame")
	choicesFrame.Name = "Choices"
	choicesFrame.BackgroundTransparency = 1
	choicesFrame.Size = UDim2.fromScale(0.9, 0.3)
	choicesFrame.Position = UDim2.fromScale(0.5, 0.36)
	choicesFrame.AnchorPoint = Vector2.new(0.5, 0)
	choicesFrame.Parent = overlay

	choicesSizeConstraint = Instance.new("UISizeConstraint")
	choicesSizeConstraint.MinSize = Vector2.new(300, 148)
	choicesSizeConstraint.MaxSize = Vector2.new(920, 220)
	choicesSizeConstraint.Parent = choicesFrame

	choicesLayout = Instance.new("UIListLayout")
	choicesLayout.FillDirection = Enum.FillDirection.Horizontal
	choicesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	choicesLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	choicesLayout.SortOrder = Enum.SortOrder.LayoutOrder
	choicesLayout.Padding = UDim.new(0, 12)
	choicesLayout.Parent = choicesFrame

	for index = 1, 3 do
		buttons[index] = createButton(choicesFrame, index)
	end

	applyChoiceLayout()

	local camera = workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyChoiceLayout)
	end
end

local function showChoices(choices)
	overlay.Enabled = true
	applyChoiceLayout()
	FeedbackAudioController.play(FeedbackEvents.LevelUp)

	for index, button in ipairs(buttons) do
		if buttonConnections[index] then
			buttonConnections[index]:Disconnect()
			buttonConnections[index] = nil
		end

		local choice = choices[index]
		if choice then
			button.Visible = true
			setChoiceButton(button, choice)

			buttonConnections[index] = button.Activated:Connect(function()
				overlay.Enabled = false
				for connectionIndex, connection in pairs(buttonConnections) do
					connection:Disconnect()
					buttonConnections[connectionIndex] = nil
				end
				FeedbackAudioController.play(FeedbackEvents.UpgradeSelect)
				Remotes.get(Remotes.Names.SelectUpgrade):FireServer(choice.id)
			end)
		else
			button.Visible = false
		end
	end
end

function LevelUpController.start()
	buildUi()

	Remotes.get(Remotes.Names.LevelUpChoices).OnClientEvent:Connect(showChoices)
end

return LevelUpController
