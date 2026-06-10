local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = require(Shared:WaitForChild("Assets"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local HudController = {}

local HUD_SOURCE_SIZE = Vector2.new(256, 128)
local HUD_DISPLAY_SIZE = Vector2.new(360, 180)
local HUD_TOP_MARGIN = 14
local HUD_RIGHT_MARGIN = 16
local HUD_MOBILE_SCALE = 0.195
local HUD_ASSET = Assets.v1_0.hud.goblin_cartoon_hud_256x128_v4

local localPlayer = Players.LocalPlayer
local hudPanel
local healthFill
local healthText
local levelText
local experienceFill
local experienceText
local timeText
local statusText

local function formatTime(totalSeconds)
	local minutes = math.floor(totalSeconds / 60)
	local seconds = math.floor(totalSeconds % 60)
	return string.format("%02d:%02d", minutes, seconds)
end

local function getHudScale()
	local camera = workspace.CurrentCamera
	local viewportSize = camera and camera.ViewportSize or Vector2.new(1280, 720)
	if UserInputService.TouchEnabled or viewportSize.X < 900 or viewportSize.Y < 560 then
		return HUD_MOBILE_SCALE
	end
	return 1
end

local function applyHudLayout()
	if not hudPanel or not timeText then
		return
	end

	local scale = getHudScale()
	local hudWidth = HUD_DISPLAY_SIZE.X * scale
	local hudHeight = HUD_DISPLAY_SIZE.Y * scale
	local marginRight = HUD_RIGHT_MARGIN
	local marginTop = HUD_TOP_MARGIN

	hudPanel.Position = UDim2.new(1, -marginRight, 0, marginTop)
	hudPanel.Size = UDim2.fromOffset(hudWidth, hudHeight)

	timeText.Position = UDim2.new(1, -marginRight - hudWidth, 0, marginTop + hudHeight + (2 * scale))
	timeText.Size = UDim2.fromOffset(150 * scale, 24 * scale)
end

local function createLabel(parent, name, text, position, size)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Position = position
	label.Size = size
	label.Parent = parent
	return label
end

local function fromSourceRect(x, y, width, height)
	return UDim2.fromScale(x / HUD_SOURCE_SIZE.X, y / HUD_SOURCE_SIZE.Y), UDim2.fromScale(width / HUD_SOURCE_SIZE.X, height / HUD_SOURCE_SIZE.Y)
end

local function createHudLabel(parent, name, text, x, y, width, height, textSize)
	local position, size = fromSourceRect(x, y, width, height)
	local label = createLabel(parent, name, text, position, size)
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextStrokeColor3 = Color3.fromRGB(25, 18, 12)
	label.TextStrokeTransparency = 0.25
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.ZIndex = 4

	local sizeLimit = Instance.new("UITextSizeConstraint")
	sizeLimit.MinTextSize = 8
	sizeLimit.MaxTextSize = textSize
	sizeLimit.Parent = label

	return label
end

local function createBar(parent, name, x, y, width, height, color)
	local position, size = fromSourceRect(x, y, width, height)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Position = position
	frame.Size = size
	frame.ClipsDescendants = true
	frame.ZIndex = 2
	frame.Parent = parent

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = color
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale(1, 1)
	fill.ZIndex = 2
	fill.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = fill

	return fill
end

local function buildHud()
	local playerGui = localPlayer:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GoblinHud"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	hudPanel = Instance.new("ImageLabel")
	hudPanel.Name = "StatsPanel"
	hudPanel.AnchorPoint = Vector2.new(1, 0)
	hudPanel.BackgroundTransparency = 1
	hudPanel.BorderSizePixel = 0
	hudPanel.Image = HUD_ASSET
	hudPanel.ZIndex = 1
	hudPanel.Parent = screenGui

	local aspectRatio = Instance.new("UIAspectRatioConstraint")
	aspectRatio.AspectRatio = HUD_SOURCE_SIZE.X / HUD_SOURCE_SIZE.Y
	aspectRatio.Parent = hudPanel

	healthFill = createBar(hudPanel, "HealthBar", 105, 43, 128, 13, Color3.fromRGB(219, 65, 54))
	healthText = createHudLabel(hudPanel, "HealthText", "100 / 100", 108, 41, 122, 18, 13)

	levelText = createHudLabel(hudPanel, "LevelText", "Lv 1", 144, 61, 56, 17, 13)
	levelText.TextColor3 = Color3.fromRGB(255, 221, 121)

	experienceFill = createBar(hudPanel, "ExperienceBar", 105, 78, 128, 13, Color3.fromRGB(89, 165, 255))
	experienceText = createHudLabel(hudPanel, "ExperienceText", "0 / 30", 108, 76, 122, 18, 13)

	statusText = createLabel(screenGui, "StatusText", "", UDim2.fromScale(0.36, 0.08), UDim2.fromScale(0.28, 0.06))
	statusText.TextXAlignment = Enum.TextXAlignment.Center

	timeText = createLabel(screenGui, "TimeText", "Time 00:00", UDim2.fromOffset(0, 0), UDim2.fromOffset(150, 24))
	timeText.TextStrokeColor3 = Color3.fromRGB(25, 18, 12)
	timeText.TextStrokeTransparency = 0.25

	applyHudLayout()

	local camera = workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyHudLayout)
	end
end

local function updateHud(stats)
	local healthRatio = 0
	if stats.maxHealth > 0 then
		healthRatio = math.clamp(stats.health / stats.maxHealth, 0, 1)
	end

	local experienceRatio = 0
	if stats.experienceToNextLevel > 0 then
		experienceRatio = math.clamp(stats.experience / stats.experienceToNextLevel, 0, 1)
	end

	healthText.Text = string.format("%d / %d", stats.health, stats.maxHealth)
	healthFill.Size = UDim2.fromScale(healthRatio, 1)

	levelText.Text = string.format("Lv %d", stats.level)
	timeText.Text = string.format("Time %s", formatTime(stats.survivalTime))

	experienceText.Text = string.format("%d / %d", stats.experience, stats.experienceToNextLevel)
	experienceFill.Size = UDim2.fromScale(experienceRatio, 1)

	statusText.Text = stats.alive and "" or "Defeated"
end

function HudController.start()
	buildHud()

	Remotes.get(Remotes.Names.PlayerStatsChanged).OnClientEvent:Connect(updateHud)
end

return HudController
