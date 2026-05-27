local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = require(Shared:WaitForChild("Assets"))
local GoblinAppearanceStages = require(Shared:WaitForChild("GoblinAppearanceStages"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local GoblinAppearanceController = {}

local localPlayer = Players.LocalPlayer
local latestAppearanceStage = GoblinAppearanceStages.getStageForSnapshot(nil)
local playerAssets = Assets.v0_4.ingame_2d
local PLAYER_SPRITE_SIZE = Vector2.new(144, 144)
local MIN_ROTATION_DISTANCE = 0.03
local characterDescendantConnection = nil
local playerSprite = nil
local lastRootPosition = nil
local lastSpriteRotation = 0

local function getSpriteRotationForFlatDirection(direction)
	return math.deg(math.atan2(direction.X, -direction.Z)) + 180
end

local function hideCharacterVisual(descendant, color)
	if descendant:IsA("BasePart") then
		descendant.Color = color
		descendant.Transparency = 1
		descendant.LocalTransparencyModifier = 1
		descendant.CastShadow = false
	elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
		descendant.Transparency = 1
	end
end

local function applyBodyColor(character, color)
	for _, descendant in ipairs(character:GetDescendants()) do
		hideCharacterVisual(descendant, color)
	end
end

local function ensurePlayerSprite(character)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local existing = root:FindFirstChild("CombatSprite")
	if existing then
		playerSprite = existing:FindFirstChild("Sprite")
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
	sprite.Rotation = lastSpriteRotation
	sprite.Parent = billboard
	playerSprite = sprite
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

	if characterDescendantConnection then
		characterDescendantConnection:Disconnect()
		characterDescendantConnection = nil
	end

	characterDescendantConnection = character.DescendantAdded:Connect(function(descendant)
		hideCharacterVisual(descendant, color)
	end)
end

local function applyPayload(payload)
	if type(payload) == "table" and type(payload.appearanceStage) == "table" then
		latestAppearanceStage = payload.appearanceStage
		applyAppearance()
	end
end

local function updatePlayerSpriteRotation()
	local character = localPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not playerSprite then
		lastRootPosition = nil
		return
	end

	applyAppearance()

	local currentPosition = root.Position
	if lastRootPosition then
		local movement = currentPosition - lastRootPosition
		local flatMovement = Vector3.new(movement.X, 0, movement.Z)
		if flatMovement.Magnitude >= MIN_ROTATION_DISTANCE then
			lastSpriteRotation = getSpriteRotationForFlatDirection(flatMovement)
			playerSprite.Rotation = lastSpriteRotation
		end
	end

	lastRootPosition = currentPosition
end

function GoblinAppearanceController.start()
	localPlayer.CharacterAdded:Connect(function()
		playerSprite = nil
		lastRootPosition = nil
		task.defer(applyAppearance)
	end)

	local ok, payload = pcall(function()
		return Remotes.get(Remotes.FunctionNames.GetMetaProgressionSnapshot):InvokeServer()
	end)
	if ok then
		applyPayload(payload)
	end

	Remotes.get(Remotes.Names.MetaProgressionChanged).OnClientEvent:Connect(applyPayload)
	RunService.RenderStepped:Connect(updatePlayerSpriteRotation)
	applyAppearance()
end

return GoblinAppearanceController
