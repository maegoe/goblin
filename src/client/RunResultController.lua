local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))

local RunResultController = {}

local localPlayer = Players.LocalPlayer
local resultGui
local panel
local titleText
local summaryText
local rewardText
local totalText

local function formatTime(totalSeconds)
	local minutes = math.floor(totalSeconds / 60)
	local seconds = math.floor(totalSeconds % 60)
	return string.format("%02d:%02d", minutes, seconds)
end

local function createLabel(parent, name, position, size, textSize)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = false
	label.TextSize = textSize
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Position = position
	label.Size = size
	label.Parent = parent
	return label
end

local function buildResultUi()
	local playerGui = localPlayer:WaitForChild("PlayerGui")

	resultGui = Instance.new("ScreenGui")
	resultGui.Name = "GoblinRunResult"
	resultGui.ResetOnSpawn = false
	resultGui.IgnoreGuiInset = true
	resultGui.Enabled = false
	resultGui.Parent = playerGui

	local dim = Instance.new("Frame")
	dim.Name = "Dim"
	dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	dim.BackgroundTransparency = 0.35
	dim.BorderSizePixel = 0
	dim.Size = UDim2.fromScale(1, 1)
	dim.Parent = resultGui

	panel = Instance.new("Frame")
	panel.Name = "ResultPanel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.BackgroundColor3 = Color3.fromRGB(18, 20, 25)
	panel.BackgroundTransparency = 0.04
	panel.BorderSizePixel = 0
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromOffset(420, 280)
	panel.Parent = dim

	titleText = createLabel(panel, "Title", UDim2.fromOffset(24, 22), UDim2.fromOffset(372, 40), 30)
	summaryText = createLabel(panel, "Summary", UDim2.fromOffset(24, 78), UDim2.fromOffset(372, 76), 20)
	rewardText = createLabel(panel, "Rewards", UDim2.fromOffset(24, 164), UDim2.fromOffset(372, 58), 22)
	totalText = createLabel(panel, "Totals", UDim2.fromOffset(24, 232), UDim2.fromOffset(372, 28), 16)
	totalText.TextColor3 = Color3.fromRGB(190, 198, 210)
end

local function showResult(result)
	if not resultGui then
		buildResultUi()
	end

	local progression = result.Progression or {}
	titleText.Text = result.EndReason == "Defeat" and "Run Defeated" or "Run Ended"
	summaryText.Text = string.format(
		"Survival %s\nKills %d\nLevel Reached %d",
		formatTime(result.SurvivalTime or 0),
		result.KillCount or 0,
		result.LevelReached or 1
	)
	rewardText.Text = string.format(
		"+%d Growth Stones\n+%d Camp Materials",
		result.GrowthStonesEarned or 0,
		result.CampMaterialsEarned or 0
	)
	totalText.Text = string.format(
		"Total: %d Growth Stones / %d Camp Materials",
		progression.GrowthStones or 0,
		progression.CampMaterials or 0
	)

	resultGui.Enabled = true
end

function RunResultController.start()
	buildResultUi()
	Remotes.get(Remotes.Names.RunEnded).OnClientEvent:Connect(showResult)
end

return RunResultController
