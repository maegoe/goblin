local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ArenaConfig = require(Shared:WaitForChild("ArenaConfig"))
local EnemyDefinitions = require(Shared:WaitForChild("EnemyDefinitions"))
local EnemyStatScaling = require(Shared:WaitForChild("EnemyStatScaling"))

local DamageNumberService = require(script.Parent:WaitForChild("DamageNumberService"))
local EnemyVisuals = require(script.Parent:WaitForChild("EnemyVisuals"))
local PlayerStateService = require(script.Parent:WaitForChild("PlayerStateService"))

local EnemyService = {}

local enemies = {}
local enemyFolder

local function getCollisionRadius(definition)
	if definition.CollisionRadius then
		return definition.CollisionRadius
	end

	local size = definition.Size
	return math.max(size.X, size.Z) * 0.5
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

function EnemyService.spawn(enemyType, position, sessionElapsed)
	local definition = EnemyDefinitions[enemyType]
	if not definition then
		warn(string.format("[goblin] Unknown enemy type: %s", tostring(enemyType)))
		return nil
	end

	local scaledStats = EnemyStatScaling.apply(definition, sessionElapsed)
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
	local sprite, spriteSheet = EnemyVisuals.createSprite(enemy, definition)

	enemy:SetAttribute("EnemyType", enemyType)
	enemy:SetAttribute("BaseMaxHealth", definition.MaxHealth)
	enemy:SetAttribute("AppliedMaxHealth", scaledStats.MaxHealth)
	enemy:SetAttribute("BaseMoveSpeed", definition.MoveSpeed)
	enemy:SetAttribute("AppliedMoveSpeed", scaledStats.MoveSpeed)
	enemy:SetAttribute("BaseContactDamage", definition.ContactDamage)
	enemy:SetAttribute("AppliedContactDamage", scaledStats.ContactDamage)
	enemy:SetAttribute("BaseAttackDamage", definition.ContactDamage)
	enemy:SetAttribute("AppliedAttackDamage", scaledStats.ContactDamage)
	enemy:SetAttribute("CurrentHealth", scaledStats.MaxHealth)
	enemy:SetAttribute("StatScaleElapsedSeconds", scaledStats.ElapsedSeconds)
	enemy:SetAttribute("StatScaleProgress", scaledStats.Progress)
	enemy:SetAttribute("HealthScale", scaledStats.Multipliers.MaxHealth)
	enemy:SetAttribute("MoveSpeedScale", scaledStats.Multipliers.MoveSpeed)
	enemy:SetAttribute("DamageScale", scaledStats.Multipliers.ContactDamage)

	enemies[enemy] = {
		Instance = enemy,
		Sprite = sprite,
		SpriteSheet = spriteSheet,
		SpawnedAt = os.clock(),
		CurrentSpriteFrame = 0,
		Type = enemyType,
		Health = scaledStats.MaxHealth,
		MaxHealth = scaledStats.MaxHealth,
		MoveSpeed = scaledStats.MoveSpeed,
		CollisionRadius = getCollisionRadius(definition),
		ContactDamage = scaledStats.ContactDamage,
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

	DamageNumberService.show(enemy.Position, amount)
	data.Health -= amount
	enemy:SetAttribute("CurrentHealth", math.max(0, data.Health))

	if data.Health <= 0 then
		enemies[enemy] = nil
		enemy:Destroy()
		return {
			enemyType = data.Type,
			experienceReward = data.ExperienceReward,
		}
	end

	if data.Sprite then
		data.Sprite.ImageTransparency = 0
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
			EnemyVisuals.animateSpriteSheet(data, now)

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
