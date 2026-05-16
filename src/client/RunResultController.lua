local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = require(Shared:WaitForChild("Assets"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local RunResultController = {}

local localPlayer = Players.LocalPlayer
local resultGui
local panel
local titleText
local summaryText
local rewardText
local totalText
local campAssets = Assets.v0_4.camp_ui

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

	panel = Instance.new("ImageLabel")
	panel.Name = "ResultPanel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.BackgroundColor3 = Color3.fromRGB(18, 20, 25)
	panel.BackgroundTransparency = 1
	panel.BorderSizePixel = 0
	panel.Image = campAssets.camp_panel_result_default_768x384
	panel.ScaleType = Enum.ScaleType.Stretch
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromOffset(520, 320)
	panel.Parent = dim

	titleText = createLabel(panel, "Title", UDim2.fromOffset(36, 28), UDim2.fromOffset(448, 40), 30)
	summaryText = createLabel(panel, "Summary", UDim2.fromOffset(36, 84), UDim2.fromOffset(448, 76), 20)
	rewardText = createLabel(panel, "Rewards", UDim2.fromOffset(36, 170), UDim2.fromOffset(448, 58), 22)
	totalText = createLabel(panel, "Totals", UDim2.fromOffset(36, 238), UDim2.fromOffset(448, 28), 16)
	totalText.TextColor3 = Color3.fromRGB(190, 198, 210)

	local campButton = Instance.new("ImageButton")
	campButton.Name = "ReturnToCamp"
	campButton.BackgroundTransparency = 1
	campButton.Image = campAssets.camp_button_primary_default_512x128
	campButton.Position = UDim2.fromOffset(330, 262)
	campButton.Size = UDim2.fromOffset(150, 38)
	campButton.ScaleType = Enum.ScaleType.Stretch
	campButton.Parent = panel
	campButton.Activated:Connect(function()
		resultGui.Enabled = false
	end)

	local campLabel = createLabel(campButton, "Label", UDim2.fromScale(0.08, 0.12), UDim2.fromScale(0.84, 0.76), 16)
	campLabel.Text = "Camp"
	campLabel.TextXAlignment = Enum.TextXAlignment.Center
	campLabel.TextYAlignment = Enum.TextYAlignment.Center
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
