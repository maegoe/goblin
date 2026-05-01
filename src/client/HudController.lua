local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))

local HudController = {}

local localPlayer = Players.LocalPlayer
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

local function createBar(parent, name, position)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundColor3 = Color3.fromRGB(25, 28, 34)
	frame.BorderSizePixel = 0
	frame.Position = position
	frame.Size = UDim2.fromOffset(260, 18)
	frame.Parent = parent

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = Color3.fromRGB(96, 205, 118)
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale(1, 1)
	fill.Parent = frame

	return fill
end

local function buildHud()
	local playerGui = localPlayer:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GoblinHud"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	local panel = Instance.new("Frame")
	panel.Name = "StatsPanel"
	panel.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
	panel.BackgroundTransparency = 0.2
	panel.BorderSizePixel = 0
	panel.Position = UDim2.fromOffset(18, 18)
	panel.Size = UDim2.fromOffset(292, 132)
	panel.Parent = screenGui

	healthText = createLabel(panel, "HealthText", "Health 100 / 100", UDim2.fromOffset(16, 12), UDim2.fromOffset(260, 22))
	healthFill = createBar(panel, "HealthBar", UDim2.fromOffset(16, 38))
	healthFill.BackgroundColor3 = Color3.fromRGB(219, 82, 82)

	levelText = createLabel(panel, "LevelText", "Level 1", UDim2.fromOffset(16, 64), UDim2.fromOffset(120, 22))
	timeText = createLabel(panel, "TimeText", "Time 00:00", UDim2.fromOffset(150, 64), UDim2.fromOffset(126, 22))

	experienceText = createLabel(panel, "ExperienceText", "XP 0 / 30", UDim2.fromOffset(16, 90), UDim2.fromOffset(260, 22))
	experienceFill = createBar(panel, "ExperienceBar", UDim2.fromOffset(16, 114))
	experienceFill.BackgroundColor3 = Color3.fromRGB(98, 166, 255)

	statusText = createLabel(screenGui, "StatusText", "", UDim2.fromScale(0.36, 0.08), UDim2.fromScale(0.28, 0.06))
	statusText.TextXAlignment = Enum.TextXAlignment.Center
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

	healthText.Text = string.format("Health %d / %d", stats.health, stats.maxHealth)
	healthFill.Size = UDim2.fromScale(healthRatio, 1)

	levelText.Text = string.format("Level %d", stats.level)
	timeText.Text = string.format("Time %s", formatTime(stats.survivalTime))

	experienceText.Text = string.format("XP %d / %d", stats.experience, stats.experienceToNextLevel)
	experienceFill.Size = UDim2.fromScale(experienceRatio, 1)

	statusText.Text = stats.alive and "" or "Defeated"
end

function HudController.start()
	buildHud()

	Remotes.get(Remotes.Names.PlayerStatsChanged).OnClientEvent:Connect(updateHud)
end

return HudController
