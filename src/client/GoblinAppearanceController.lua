local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = require(Shared:WaitForChild("Assets"))
local GoblinAppearanceStages = require(Shared:WaitForChild("GoblinAppearanceStages"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local GoblinAppearanceController = {}

local localPlayer = Players.LocalPlayer
local latestAppearanceStage = GoblinAppearanceStages.getStageForSnapshot(nil)
local playerAssets = Assets.v0_4.ingame_2d
local PLAYER_SPRITE_SIZE = Vector2.new(54, 54)
local PLAYER_SPRITE_FRAME_SIZE = Vector2.new(128, 128)
local PLAYER_SPRITE_COLUMNS = 8
local PLAYER_SPRITE_FRAME_COUNT = 8
local PLAYER_SPRITE_FPS = 10
local PLAYER_SPRITES = {
	idle = {
		Image = "rbxassetid://118274519536442",
	},
	walkLeft = {
		Image = "rbxassetid://139275661229908",
	},
	walkRight = {
		Image = "rbxassetid://90889400666043",
	},
}
local DIRECTION_KEY_BY_KEY_CODE = {
	[Enum.KeyCode.W] = "up",
	[Enum.KeyCode.Up] = "up",
	[Enum.KeyCode.DPadUp] = "up",
	[Enum.KeyCode.S] = "down",
	[Enum.KeyCode.Down] = "down",
	[Enum.KeyCode.DPadDown] = "down",
	[Enum.KeyCode.A] = "left",
	[Enum.KeyCode.Left] = "left",
	[Enum.KeyCode.DPadLeft] = "left",
	[Enum.KeyCode.D] = "right",
	[Enum.KeyCode.Right] = "right",
	[Enum.KeyCode.DPadRight] = "right",
}
local characterDescendantConnection = nil
local playerSprite = nil
local currentSpriteState = "idle"
local lastPlayedSpriteState = "idle"
local currentSpriteFrame = 0
local spriteFrameElapsed = 0
local shouldAnimateSprite = true
local hasSeenDirectionalInput = false
local directionInput = {
	up = false,
	down = false,
	left = false,
	right = false,
}

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
	sprite.Image = PLAYER_SPRITES.idle.Image or playerAssets.combat_goblin_player_default_512x512
	sprite.ImageRectSize = PLAYER_SPRITE_FRAME_SIZE
	sprite.ImageRectOffset = Vector2.new(0, 0)
	sprite.ScaleType = Enum.ScaleType.Fit
	sprite.Size = UDim2.fromScale(1, 1)
	sprite.Rotation = 0
	sprite.Parent = billboard
	playerSprite = sprite
end

local function setPlayerSpriteFrame(frameIndex)
	if not playerSprite then
		return
	end

	local safeFrameIndex = math.clamp(frameIndex, 0, PLAYER_SPRITE_FRAME_COUNT - 1)
	local column = safeFrameIndex % PLAYER_SPRITE_COLUMNS
	local row = math.floor(safeFrameIndex / PLAYER_SPRITE_COLUMNS)
	playerSprite.ImageRectSize = PLAYER_SPRITE_FRAME_SIZE
	playerSprite.ImageRectOffset = Vector2.new(PLAYER_SPRITE_FRAME_SIZE.X * column, PLAYER_SPRITE_FRAME_SIZE.Y * row)
	currentSpriteFrame = safeFrameIndex
end

local function setPlayerSpriteState(spriteState, animate)
	local spriteConfig = PLAYER_SPRITES[spriteState] or PLAYER_SPRITES.idle
	currentSpriteState = spriteState
	shouldAnimateSprite = animate

	if playerSprite then
		playerSprite.Image = spriteConfig.Image or playerAssets.combat_goblin_player_default_512x512
		playerSprite.Rotation = 0
	end

	if lastPlayedSpriteState ~= spriteState then
		spriteFrameElapsed = 0
		setPlayerSpriteFrame(0)
	end

	if animate then
		lastPlayedSpriteState = spriteState
	else
		setPlayerSpriteFrame(0)
	end
end

local function getRequestedSpriteState()
	local up = directionInput.up
	local down = directionInput.down
	local left = directionInput.left
	local right = directionInput.right
	local anyPressed = up or down or left or right

	if not anyPressed then
		if hasSeenDirectionalInput then
			return lastPlayedSpriteState, false
		end

		return "idle", true
	end

	hasSeenDirectionalInput = true

	if up and down and left and right then
		return "idle", true
	end

	if left and right then
		if up and not down then
			return "walkLeft", true
		elseif down and not up then
			return "walkRight", true
		end

		return "idle", true
	end

	if left then
		return "walkLeft", true
	elseif right then
		return "walkRight", true
	elseif up and not down then
		return "walkLeft", true
	elseif down and not up then
		return "walkRight", true
	end

	return "idle", true
end

local function setDirectionInput(keyCode, isPressed)
	local direction = DIRECTION_KEY_BY_KEY_CODE[keyCode]
	if not direction then
		return
	end

	directionInput[direction] = isPressed
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

local function updatePlayerSprite(deltaTime)
	local character = localPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not playerSprite then
		return
	end

	applyAppearance()

	local requestedState, animate = getRequestedSpriteState()
	if currentSpriteState ~= requestedState or shouldAnimateSprite ~= animate then
		setPlayerSpriteState(requestedState, animate)
	end

	if not shouldAnimateSprite then
		return
	end

	spriteFrameElapsed += deltaTime
	local frameDuration = 1 / PLAYER_SPRITE_FPS
	if spriteFrameElapsed < frameDuration then
		return
	end

	local framesToAdvance = math.floor(spriteFrameElapsed / frameDuration)
	spriteFrameElapsed -= framesToAdvance * frameDuration
	setPlayerSpriteFrame((currentSpriteFrame + framesToAdvance) % PLAYER_SPRITE_FRAME_COUNT)
end

function GoblinAppearanceController.start()
	localPlayer.CharacterAdded:Connect(function()
		playerSprite = nil
		currentSpriteState = "idle"
		lastPlayedSpriteState = "idle"
		currentSpriteFrame = 0
		spriteFrameElapsed = 0
		shouldAnimateSprite = true
		hasSeenDirectionalInput = false
		task.defer(applyAppearance)
	end)

	UserInputService.InputBegan:Connect(function(input)
		if UserInputService:GetFocusedTextBox() then
			return
		end

		setDirectionInput(input.KeyCode, true)
	end)

	UserInputService.InputEnded:Connect(function(input)
		setDirectionInput(input.KeyCode, false)
	end)

	local ok, payload = pcall(function()
		return Remotes.get(Remotes.FunctionNames.GetMetaProgressionSnapshot):InvokeServer()
	end)
	if ok then
		applyPayload(payload)
	end

	Remotes.get(Remotes.Names.MetaProgressionChanged).OnClientEvent:Connect(applyPayload)
	RunService.RenderStepped:Connect(updatePlayerSprite)
	applyAppearance()
end

return GoblinAppearanceController
