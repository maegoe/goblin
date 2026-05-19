local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = require(Shared:WaitForChild("Assets"))
local GoblinAppearanceStages = require(Shared:WaitForChild("GoblinAppearanceStages"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local GoblinAppearanceController = {}

local localPlayer = Players.LocalPlayer
local latestAppearanceStage = GoblinAppearanceStages.getStageForSnapshot(nil)
local playerAssets = Assets.v0_4.ingame_2d
local PLAYER_SPRITE_SIZE = Vector2.new(144, 144)

local function applyBodyColor(character, color)
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" then
			descendant.Color = color
			descendant.LocalTransparencyModifier = 1
		elseif descendant:IsA("Decal") then
			descendant.Transparency = 1
		end
	end
end

local function ensurePlayerSprite(character)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local existing = root:FindFirstChild("CombatSprite")
	if existing then
		return
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "CombatSprite"
	billboard.Adornee = root
	billboard.AlwaysOnTop = false
	billboard.LightInfluence = 0
	billboard.MaxDistance = 250
	billboard.Size = UDim2.fromOffset(PLAYER_SPRITE_SIZE.X, PLAYER_SPRITE_SIZE.Y)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 0.25, 0)
	billboard.Parent = root

	local sprite = Instance.new("ImageLabel")
	sprite.Name = "Sprite"
	sprite.BackgroundTransparency = 1
	sprite.Image = playerAssets.combat_goblin_player_default_512x512
	sprite.ScaleType = Enum.ScaleType.Fit
	sprite.Size = UDim2.fromScale(1, 1)
	sprite.Parent = billboard
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
	ensurePlayerSprite(character)
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
