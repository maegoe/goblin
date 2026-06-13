local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))

local HudController = {}

local HUD_BASE_SIZE = Vector2.new(430, 140)
local HUD_TOP_MARGIN = 16
local HUD_RIGHT_MARGIN = 16
local HUD_MOBILE_SCALE = 0.78
local TEXT_LIGHT = Color3.fromRGB(238, 231, 204)
local TEXT_MUTED = Color3.fromRGB(157, 168, 129)
local PANEL_DARK = Color3.fromRGB(18, 23, 17)
local PANEL_DARKER = Color3.fromRGB(7, 10, 8)
local STROKE_SOFT = Color3.fromRGB(112, 122, 82)
local HEALTH_COLOR = Color3.fromRGB(188, 61, 47)
local HEALTH_COLOR_2 = Color3.fromRGB(230, 112, 65)
local XP_COLOR = Color3.fromRGB(74, 183, 139)
local XP_COLOR_2 = Color3.fromRGB(143, 226, 163)
local GOLD = Color3.fromRGB(218, 184, 91)

local localPlayer = Players.LocalPlayer
local screenGui
local hudRoot
local hudScale
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

local function createCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

local function createStroke(parent, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Transparency = transparency or 0
	stroke.Parent = parent
	return stroke
end

local function createGradient(parent, topColor, bottomColor, rotation)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, topColor),
		ColorSequenceKeypoint.new(1, bottomColor),
	})
	gradient.Rotation = rotation or 90
	gradient.Parent = parent
	return gradient
end

local function createLabel(parent, name, text, position, size, textSize, color, font)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Font = font or Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = color or TEXT_LIGHT
	label.TextScaled = false
	label.TextSize = textSize
	label.TextWrapped = false
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Position = position
	label.Size = size
	label.ZIndex = parent.ZIndex + 1
	label.Parent = parent

	return label
end

local function createPill(parent, name, position, size, accentColor)
	local pill = Instance.new("Frame")
	pill.Name = name
	pill.BackgroundColor3 = Color3.fromRGB(25, 29, 20)
	pill.BackgroundTransparency = 0.08
	pill.BorderSizePixel = 0
	pill.Position = position
	pill.Size = size
	pill.ZIndex = parent.ZIndex + 1
	pill.Parent = parent
	createCorner(pill, 12)
	createStroke(pill, accentColor, 1, 0.42)
	createGradient(pill, Color3.fromRGB(39, 45, 31), Color3.fromRGB(12, 15, 11), 90)
	return pill
end

local function createStatBar(parent, name, label, position, colorA, colorB)
	local row = Instance.new("Frame")
	row.Name = name
	row.BackgroundColor3 = Color3.fromRGB(14, 18, 13)
	row.BackgroundTransparency = 0.1
	row.BorderSizePixel = 0
	row.Position = position
	row.Size = UDim2.fromOffset(398, 34)
	row.ZIndex = parent.ZIndex + 1
	row.Parent = parent
	createCorner(row, 12)
	createStroke(row, Color3.fromRGB(91, 101, 68), 1, 0.42)
	createGradient(row, Color3.fromRGB(26, 31, 22), Color3.fromRGB(9, 12, 9), 90)

	createLabel(row, "Label", label, UDim2.fromOffset(14, 3), UDim2.fromOffset(54, 14), 12, TEXT_MUTED, Enum.Font.GothamBlack)

	local value = createLabel(row, "Value", "0 / 0", UDim2.fromOffset(284, 3), UDim2.fromOffset(100, 14), 12, TEXT_LIGHT, Enum.Font.GothamBold)
	value.TextXAlignment = Enum.TextXAlignment.Right

	local track = Instance.new("Frame")
	track.Name = "Track"
	track.BackgroundColor3 = Color3.fromRGB(21, 25, 19)
	track.BorderSizePixel = 0
	track.Position = UDim2.fromOffset(14, 20)
	track.Size = UDim2.fromOffset(370, 10)
	track.ClipsDescendants = true
	track.ZIndex = row.ZIndex + 1
	track.Parent = row
	createCorner(track, 6)
	createStroke(track, Color3.fromRGB(71, 79, 57), 1, 0.55)

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = colorA
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale(1, 1)
	fill.ZIndex = track.ZIndex + 1
	fill.Parent = track
	createCorner(fill, 6)
	createGradient(fill, colorA, colorB, 0)

	local shine = Instance.new("Frame")
	shine.Name = "Shine"
	shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	shine.BackgroundTransparency = 0.82
	shine.BorderSizePixel = 0
	shine.Size = UDim2.fromScale(1, 0.38)
	shine.ZIndex = fill.ZIndex + 1
	shine.Parent = fill
	createCorner(shine, 6)

	return fill, value
end

local function applyHudLayout()
	if not hudRoot then
		return
	end

	local scale = getHudScale()
	hudRoot.AnchorPoint = Vector2.new(1, 0)
	hudRoot.Position = UDim2.new(1, -HUD_RIGHT_MARGIN, 0, HUD_TOP_MARGIN)
	hudRoot.Size = UDim2.fromOffset(HUD_BASE_SIZE.X, HUD_BASE_SIZE.Y)
	if hudScale then
		hudScale.Scale = scale
	end
end

local function buildHud()
	local playerGui = localPlayer:WaitForChild("PlayerGui")

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GoblinHud"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.Parent = playerGui

	hudRoot = Instance.new("Frame")
	hudRoot.Name = "Root"
	hudRoot.BackgroundTransparency = 1
	hudRoot.BorderSizePixel = 0
	hudRoot.Parent = screenGui

	hudScale = Instance.new("UIScale")
	hudScale.Name = "HudScale"
	hudScale.Scale = 1
	hudScale.Parent = hudRoot

	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency = 0.62
	shadow.BorderSizePixel = 0
	shadow.Position = UDim2.fromOffset(4, 5)
	shadow.Size = UDim2.fromScale(1, 1)
	shadow.ZIndex = 1
	shadow.Parent = hudRoot
	createCorner(shadow, 16)

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.BackgroundColor3 = PANEL_DARK
	panel.BackgroundTransparency = 0.08
	panel.BorderSizePixel = 0
	panel.Size = UDim2.fromScale(1, 1)
	panel.ZIndex = 2
	panel.Parent = hudRoot
	createCorner(panel, 16)
	createStroke(panel, STROKE_SOFT, 1.4, 0.18)
	createGradient(panel, Color3.fromRGB(31, 38, 27), PANEL_DARKER, 90)

	local accent = Instance.new("Frame")
	accent.Name = "AccentRail"
	accent.BackgroundColor3 = Color3.fromRGB(118, 170, 92)
	accent.BackgroundTransparency = 0
	accent.BorderSizePixel = 0
	accent.Position = UDim2.fromOffset(0, 16)
	accent.Size = UDim2.fromOffset(4, 108)
	accent.ZIndex = panel.ZIndex + 1
	accent.Parent = panel
	createCorner(accent, 4)
	createGradient(accent, Color3.fromRGB(118, 170, 92), Color3.fromRGB(91, 156, 126), 90)

	local levelPill = createPill(panel, "LevelPill", UDim2.fromOffset(16, 14), UDim2.fromOffset(100, 32), GOLD)
	levelText = createLabel(levelPill, "Text", "Lv 1", UDim2.fromOffset(12, 0), UDim2.fromOffset(76, 32), 14, GOLD, Enum.Font.GothamBlack)
	levelText.TextXAlignment = Enum.TextXAlignment.Center

	local timePill = createPill(panel, "TimePill", UDim2.fromOffset(126, 14), UDim2.fromOffset(288, 32), XP_COLOR)
	timeText = createLabel(timePill, "Text", "00:00", UDim2.fromOffset(12, 0), UDim2.fromOffset(264, 32), 14, TEXT_LIGHT, Enum.Font.GothamBlack)
	timeText.TextXAlignment = Enum.TextXAlignment.Center

	statusText = createLabel(panel, "Status", "", UDim2.fromOffset(254, 14), UDim2.fromOffset(144, 32), 12, HEALTH_COLOR_2, Enum.Font.GothamBlack)
	statusText.TextXAlignment = Enum.TextXAlignment.Right

	healthFill, healthText = createStatBar(panel, "Health", "HP", UDim2.fromOffset(16, 58), HEALTH_COLOR, HEALTH_COLOR_2)
	experienceFill, experienceText = createStatBar(panel, "Experience", "XP", UDim2.fromOffset(16, 96), XP_COLOR, XP_COLOR_2)

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
	timeText.Text = formatTime(stats.survivalTime)

	experienceText.Text = string.format("%d / %d", stats.experience, stats.experienceToNextLevel)
	experienceFill.Size = UDim2.fromScale(experienceRatio, 1)

	statusText.Text = stats.alive and "" or "DEFEATED"
end

function HudController.start()
	buildHud()

	Remotes.get(Remotes.Names.PlayerStatsChanged).OnClientEvent:Connect(updateHud)
end

return HudController
