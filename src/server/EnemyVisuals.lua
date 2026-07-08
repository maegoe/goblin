local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = require(Shared:WaitForChild("Assets"))

local EnemyVisuals = {}

local enemyAssets = Assets.v0_4.ingame_2d
local BASIC_MONSTER_SPRITE_SIZE = Vector2.new(51, 51)
local DEFAULT_SPRITE_COLOR = Color3.fromRGB(255, 255, 255)
local DEFAULT_SPRITE_SHEET_FPS = 8

local function setSpriteSheetFrame(sprite, spriteSheet, frameIndex)
	local frameSize = spriteSheet.FrameSize
	local columns = spriteSheet.Columns or spriteSheet.FrameCount or 1
	local column = frameIndex % columns
	local row = math.floor(frameIndex / columns)

	sprite.ImageRectSize = frameSize
	sprite.ImageRectOffset = Vector2.new(frameSize.X * column, frameSize.Y * row)
end

function EnemyVisuals.createSprite(parent, definition)
	local spriteSize = definition.SpriteSize or BASIC_MONSTER_SPRITE_SIZE
	local spriteColor = definition.SpriteColor or DEFAULT_SPRITE_COLOR
	local spriteSheet = definition.SpriteSheet
	local spriteImage = spriteSheet and spriteSheet.Image or enemyAssets.combat_monster_default_512x512

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "CombatSprite"
	billboard.Adornee = parent
	billboard.AlwaysOnTop = false
	billboard.LightInfluence = 0
	billboard.MaxDistance = 250
	billboard.Size = UDim2.fromOffset(spriteSize.X, spriteSize.Y)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 0.35, 0)
	billboard.Parent = parent

	local sprite = Instance.new("ImageLabel")
	sprite.Name = "Sprite"
	sprite.BackgroundTransparency = 1
	sprite.Image = spriteImage
	sprite.ImageColor3 = spriteColor
	sprite.ImageTransparency = 0
	sprite.ScaleType = Enum.ScaleType.Fit
	sprite.Size = UDim2.fromScale(1, 1)
	if spriteSheet and spriteSheet.FrameSize then
		setSpriteSheetFrame(sprite, spriteSheet, 0)
	end
	sprite.Parent = billboard

	return sprite, spriteSheet
end

function EnemyVisuals.animateSpriteSheet(data, now)
	local spriteSheet = data.SpriteSheet
	if not data.Sprite or not spriteSheet or not spriteSheet.FrameSize then
		return
	end

	local frameCount = spriteSheet.FrameCount or 1
	local framesPerSecond = spriteSheet.FramesPerSecond or DEFAULT_SPRITE_SHEET_FPS
	local frameIndex = math.floor((now - data.SpawnedAt) * framesPerSecond) % frameCount
	if data.CurrentSpriteFrame == frameIndex then
		return
	end

	data.CurrentSpriteFrame = frameIndex
	setSpriteSheetFrame(data.Sprite, spriteSheet, frameIndex)
end

return EnemyVisuals
