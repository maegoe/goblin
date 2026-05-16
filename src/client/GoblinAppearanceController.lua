local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GoblinAppearanceStages = require(Shared:WaitForChild("GoblinAppearanceStages"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local GoblinAppearanceController = {}

local localPlayer = Players.LocalPlayer
local latestAppearanceStage = GoblinAppearanceStages.getStageForSnapshot(nil)

local function applyBodyColor(character, color)
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" then
			descendant.Color = color
		end
	end
end

local function applyAppearance()
	local character = localPlayer.Character
	if not character or type(latestAppearanceStage) ~= "table" then
		return
	end

	local color = latestAppearanceStage.Color
	if typeof(color) ~= "Color3" then
		color = Color3.fromRGB(86, 154, 84)
	end
	applyBodyColor(character, color)
end

local function applyPayload(payload)
	if type(payload) == "table" and type(payload.appearanceStage) == "table" then
		latestAppearanceStage = payload.appearanceStage
		applyAppearance()
	end
end

function GoblinAppearanceController.start()
	localPlayer.CharacterAdded:Connect(function()
		task.defer(applyAppearance)
	end)

	local ok, payload = pcall(function()
		return Remotes.get(Remotes.FunctionNames.GetMetaProgressionSnapshot):InvokeServer()
	end)
	if ok then
		applyPayload(payload)
	end

	Remotes.get(Remotes.Names.MetaProgressionChanged).OnClientEvent:Connect(applyPayload)
	applyAppearance()
end

return GoblinAppearanceController
