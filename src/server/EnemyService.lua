local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local EnemyDefinitions = require(Shared:WaitForChild("EnemyDefinitions"))

local PlayerStateService = require(script.Parent:WaitForChild("PlayerStateService"))

local EnemyService = {}

local enemies = {}
local enemyFolder

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
	enemy.Anchored = true
	enemy.CanCollide = false
	enemy.Position = position
	enemy.Parent = getEnemyFolder()

	enemies[enemy] = {
		Instance = enemy,
		Type = enemyType,
		Health = definition.MaxHealth,
		MaxHealth = definition.MaxHealth,
		MoveSpeed = definition.MoveSpeed,
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
	enemy.Transparency = 1 - scale

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

			local targetPlayer, distance = getNearestPlayer(enemy.Position)
			if not targetPlayer then
				continue
			end

			local root = PlayerStateService.getRoot(targetPlayer)
			if not root then
				continue
			end

			if distance > 3.5 then
				local direction = root.Position - enemy.Position
				local flatDirection = Vector3.new(direction.X, 0, direction.Z)
				if flatDirection.Magnitude > 0 then
					enemy.Position += flatDirection.Unit * data.MoveSpeed * deltaTime
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
