local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ArenaConfig = require(Shared:WaitForChild("ArenaConfig"))
local Assets = require(Shared:WaitForChild("Assets"))
local EnemyDefinitions = require(Shared:WaitForChild("EnemyDefinitions"))

local PlayerStateService = require(script.Parent:WaitForChild("PlayerStateService"))

local EnemyService = {}

local enemies = {}
local enemyFolder
local enemyAssets = Assets.v0_4.ingame_2d
local BASIC_MONSTER_SPRITE_SIZE = Vector2.new(51, 51)
local DEFAULT_SPRITE_COLOR = Color3.fromRGB(255, 255, 255)
local DAMAGE_NUMBER_LIFETIME = 0.65
local DAMAGE_NUMBER_RISE = 2.5
local DAMAGE_NUMBER_FOLDER_NAME = "DamageNumbers"
local DEFAULT_SPRITE_SHEET_FPS = 8

local function getCollisionRadius(definition)
	if definition.CollisionRadius then
		return definition.CollisionRadius
	end

	local size = definition.Size
	return math.max(size.X, size.Z) * 0.5
end

local function setSpriteSheetFrame(sprite, spriteSheet, frameIndex)
	local frameSize = spriteSheet.FrameSize
	local columns = spriteSheet.Columns or spriteSheet.FrameCount or 1
	local column = frameIndex % columns
	local row = math.floor(frameIndex / columns)

	sprite.ImageRectSize = frameSize
	sprite.ImageRectOffset = Vector2.new(frameSize.X * column, frameSize.Y * row)
end

local function animateSpriteSheet(data, now)
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

local function createSpriteBillboard(parent, image, size, color, spriteSheet)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "CombatSprite"
	billboard.Adornee = parent
	billboard.AlwaysOnTop = false
	billboard.LightInfluence = 0
	billboard.MaxDistance = 250
	billboard.Size = UDim2.fromOffset(size.X, size.Y)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 0.35, 0)
	billboard.Parent = parent

	local sprite = Instance.new("ImageLabel")
	sprite.Name = "Sprite"
	sprite.BackgroundTransparency = 1
	sprite.Image = image
	sprite.ImageColor3 = color
	sprite.ScaleType = Enum.ScaleType.Fit
	sprite.Size = UDim2.fromScale(1, 1)
	if spriteSheet and spriteSheet.FrameSize then
		setSpriteSheetFrame(sprite, spriteSheet, 0)
	end
	sprite.Parent = billboard

	return sprite
end

local function getDamageNumberFolder()
	local folder = Workspace:FindFirstChild(DAMAGE_NUMBER_FOLDER_NAME)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = DAMAGE_NUMBER_FOLDER_NAME
		folder.Parent = Workspace
	end

	return folder
end

local function formatDamageAmount(amount)
	if amount % 1 == 0 then
		return tostring(amount)
	end

	return string.format("%.1f", amount):gsub("0+$", ""):gsub("%.$", "")
end

local function showDamageNumber(position, amount)
	local marker = Instance.new("Part")
	marker.Name = "DamageNumber"
	marker.Anchored = true
	marker.CanCollide = false
	marker.CanQuery = false
	marker.CanTouch = false
	marker.Transparency = 1
	marker.Size = Vector3.new(0.2, 0.2, 0.2)
	marker.Position = position + Vector3.new(0, 3.25, 0)
	marker.Parent = getDamageNumberFolder()

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "DamageNumberBillboard"
	billboard.Adornee = marker
	billboard.AlwaysOnTop = true
	billboard.LightInfluence = 0
	billboard.MaxDistance = 180
	billboard.Size = UDim2.fromOffset(80, 34)
	billboard.Parent = marker

	local label = Instance.new("TextLabel")
	label.Name = "Amount"
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = formatDamageAmount(amount)
	label.TextColor3 = Color3.fromRGB(255, 238, 126)
	label.TextScaled = true
	label.TextStrokeColor3 = Color3.fromRGB(44, 28, 18)
	label.TextStrokeTransparency = 0.15
	label.Size = UDim2.fromScale(1, 1)
	label.Parent = billboard

	local tweenInfo = TweenInfo.new(DAMAGE_NUMBER_LIFETIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(marker, tweenInfo, {
		Position = marker.Position + Vector3.new(0, DAMAGE_NUMBER_RISE, 0),
	}):Play()
	TweenService:Create(label, tweenInfo, {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}):Play()

	Debris:AddItem(marker, DAMAGE_NUMBER_LIFETIME + 0.1)
end

local function getEnemyFolder()
	if enemyFolder then
		return enemyFolder
	end

	enemyFolder = Workspace:FindFirstChild("Enemies")
	if not enemyFolder then
		enemyFolder = Instance.new("Folder")
		enemyFolder.Name = "Enemies"
		enemyFolder.Parent = Workspace
	end

	return enemyFolder
end

local function getNearestPlayer(position)
	local nearestPlayer = nil
	local nearestDistance = math.huge

	for _, player in ipairs(PlayerStateService.getAlivePlayers()) do
		local root = PlayerStateService.getRoot(player)
		if root then
			local distance = (root.Position - position).Magnitude
			if distance < nearestDistance then
				nearestPlayer = player
				nearestDistance = distance
			end
		end
	end

	return nearestPlayer, nearestDistance
end

local function getHorizontalDirection(fromPosition, toPosition)
	local direction = fromPosition - toPosition
	local flatDirection = Vector3.new(direction.X, 0, direction.Z)
	if flatDirection.Magnitude > 0.001 then
		return flatDirection.Unit
	end

	return Vector3.new(1, 0, 0)
end

local function separateFromOtherEnemies(enemy, data, desiredPosition)
	local separatedPosition = desiredPosition

	for otherEnemy, otherData in pairs(enemies) do
		if otherEnemy ~= enemy and otherEnemy.Parent and otherData.Health > 0 then
			local minDistance = data.CollisionRadius + otherData.CollisionRadius
			local offset = separatedPosition - otherEnemy.Position
			local flatOffset = Vector3.new(offset.X, 0, offset.Z)
			local distance = flatOffset.Magnitude

			if distance < minDistance then
				local pushDirection = getHorizontalDirection(separatedPosition, otherEnemy.Position)
				local pushDistance = minDistance - distance
				separatedPosition += pushDirection * pushDistance
			end
		end
	end

	return ArenaConfig.clampToArena(separatedPosition, ArenaConfig.EnemyMovementMargin)
end

function EnemyService.count()
	local total = 0
	for _ in pairs(enemies) do
		total += 1
	end
	return total
end

function EnemyService.clear()
	for enemy in pairs(enemies) do
		if enemy.Parent then
			enemy:Destroy()
		end
	end

	enemies = {}
end

function EnemyService.spawn(enemyType, position)
	local definition = EnemyDefinitions[enemyType]
	if not definition then
		warn(string.format("[goblin] Unknown enemy type: %s", tostring(enemyType)))
		return nil
	end

	local enemy = Instance.new("Part")
	enemy.Name = enemyType
	enemy.Shape = Enum.PartType.Ball
	enemy.Size = definition.Size
	enemy.Color = Color3.fromRGB(93, 176, 87)
	enemy.Material = Enum.Material.SmoothPlastic
	enemy.Transparency = 1
	enemy.Anchored = true
	enemy.CanCollide = false
	enemy.Position = ArenaConfig.clampToArena(position, ArenaConfig.SpawnMargin)
	enemy.Parent = getEnemyFolder()
	local spriteSize = definition.SpriteSize or BASIC_MONSTER_SPRITE_SIZE
	local spriteColor = definition.SpriteColor or DEFAULT_SPRITE_COLOR
	local spriteSheet = definition.SpriteSheet
	local spriteImage = spriteSheet and spriteSheet.Image or enemyAssets.combat_monster_default_512x512
	local sprite = createSpriteBillboard(enemy, spriteImage, spriteSize, spriteColor, spriteSheet)

	enemies[enemy] = {
		Instance = enemy,
		Sprite = sprite,
		SpriteSheet = spriteSheet,
		SpawnedAt = os.clock(),
		CurrentSpriteFrame = 0,
		Type = enemyType,
		Health = definition.MaxHealth,
		MaxHealth = definition.MaxHealth,
		MoveSpeed = definition.MoveSpeed,
		CollisionRadius = getCollisionRadius(definition),
		ContactDamage = definition.ContactDamage,
		ContactInterval = definition.ContactInterval,
		ExperienceReward = definition.ExperienceReward,
		LastContactAt = {},
	}

	return enemy
end

function EnemyService.getNearestEnemy(position, range)
	local nearestEnemy = nil
	local nearestDistance = range

	for enemy, data in pairs(enemies) do
		if enemy.Parent and data.Health > 0 then
			local distance = (enemy.Position - position).Magnitude
			if distance <= nearestDistance then
				nearestEnemy = enemy
				nearestDistance = distance
			end
		end
	end

	return nearestEnemy, nearestDistance
end

function EnemyService.getEnemiesInRadius(position, radius, excludedEnemy)
	local nearbyEnemies = {}

	for enemy, data in pairs(enemies) do
		if enemy ~= excludedEnemy and enemy.Parent and data.Health > 0 then
			local distance = (enemy.Position - position).Magnitude
			if distance <= radius then
				table.insert(nearbyEnemies, enemy)
			end
		end
	end

	return nearbyEnemies
end

function EnemyService.damage(enemy, amount)
	local data = enemies[enemy]
	if not data then
		return nil
	end

	showDamageNumber(enemy.Position, amount)
	data.Health -= amount

	if data.Health <= 0 then
		enemies[enemy] = nil
		enemy:Destroy()
		return {
			enemyType = data.Type,
			experienceReward = data.ExperienceReward,
		}
	end

	local scale = math.clamp(data.Health / data.MaxHealth, 0.25, 1)
	if data.Sprite then
		data.Sprite.ImageTransparency = 1 - scale
	end

	return nil
end

function EnemyService.start()
	getEnemyFolder()

	RunService.Heartbeat:Connect(function(deltaTime)
		if PlayerStateService.isPaused() then
			return
		end

		local now = os.clock()

		for enemy, data in pairs(enemies) do
			if not enemy.Parent then
				enemies[enemy] = nil
				continue
			end

			enemy.Position = separateFromOtherEnemies(enemy, data, enemy.Position)

			local targetPlayer, distance = getNearestPlayer(enemy.Position)
			if not targetPlayer then
				continue
			end

			local root = PlayerStateService.getRoot(targetPlayer)
			if not root then
				continue
			end

			local direction = root.Position - enemy.Position
			local flatDirection = Vector3.new(direction.X, 0, direction.Z)
			animateSpriteSheet(data, now)

			if distance > 3.5 then
				if flatDirection.Magnitude > 0 then
					local nextPosition = enemy.Position + (flatDirection.Unit * data.MoveSpeed * deltaTime)
					enemy.Position = separateFromOtherEnemies(enemy, data, nextPosition)
				end
			else
				local lastContact = data.LastContactAt[targetPlayer] or 0
				if now - lastContact >= data.ContactInterval then
					data.LastContactAt[targetPlayer] = now
					PlayerStateService.damagePlayer(targetPlayer, data.ContactDamage)
				end
			end
		end
	end)
end

return EnemyService
