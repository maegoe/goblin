local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ArenaConfig = require(Shared:WaitForChild("ArenaConfig"))
local WaveConfig = require(Shared:WaitForChild("WaveConfig"))

local EnemyService = require(script.Parent:WaitForChild("EnemyService"))
local PlayerStateService = require(script.Parent:WaitForChild("PlayerStateService"))

local WaveService = {}

local elapsed = 0
local spawnAccumulator = 0
local hadAlivePlayers = false

local function getCurrentPressureStage()
	local stages = WaveConfig.PressureStages
	if type(stages) ~= "table" then
		return nil
	end

	local currentStage = nil
	for _, stage in ipairs(stages) do
		local startsAt = stage.StartsAt
		if type(startsAt) == "number" and elapsed >= startsAt then
			currentStage = stage
		end
	end

	return currentStage
end

local function getSpawnInterval()
	return math.max(
		WaveConfig.MinimumSpawnInterval,
		WaveConfig.InitialSpawnInterval - (elapsed * WaveConfig.SpawnIntervalRampPerSecond)
	)
end

local function getEnemiesPerSpawn()
	local stage = getCurrentPressureStage()
	if stage and type(stage.EnemiesPerSpawn) == "number" then
		return stage.EnemiesPerSpawn
	end

	return WaveConfig.EnemiesPerSpawn
end

local function getMaxEnemies()
	local stage = getCurrentPressureStage()
	if stage and type(stage.MaxEnemies) == "number" then
		return stage.MaxEnemies
	end

	return WaveConfig.MaxEnemies
end

local function chooseEnemyType()
	local stage = getCurrentPressureStage()
	local weights = stage and stage.EnemyWeights
	if type(weights) ~= "table" then
		return WaveConfig.EnemyType
	end

	local totalWeight = 0
	for _, weight in pairs(weights) do
		if type(weight) == "number" and weight > 0 then
			totalWeight += weight
		end
	end

	if totalWeight <= 0 then
		return WaveConfig.EnemyType
	end

	local roll = math.random() * totalWeight
	local cursor = 0
	for enemyType, weight in pairs(weights) do
		if type(weight) == "number" and weight > 0 then
			cursor += weight
			if roll <= cursor then
				return enemyType
			end
		end
	end

	return WaveConfig.EnemyType
end

local function getFlatDistance(a, b)
	local delta = a - b
	return Vector3.new(delta.X, 0, delta.Z).Magnitude
end

local function createSpawnCandidate(rootPosition, angle, radius)
	local offset = Vector3.new(math.cos(angle) * radius, 2, math.sin(angle) * radius)
	return ArenaConfig.clampToArena(rootPosition + offset, ArenaConfig.SpawnMargin)
end

local function getSpawnPosition(rootPosition)
	local minimumDistance = WaveConfig.MinimumSpawnDistanceFromPlayer or 0
	local attempts = WaveConfig.SpawnPositionAttempts or 1
	local fallbackPosition = nil
	local fallbackDistance = -math.huge

	for _ = 1, attempts do
		local angle = math.random() * math.pi * 2
		local radius = WaveConfig.SpawnRadius + (math.random() * WaveConfig.SpawnRadiusJitter)
		local candidate = createSpawnCandidate(rootPosition, angle, radius)
		local distance = getFlatDistance(candidate, rootPosition)

		if distance >= minimumDistance then
			return candidate
		end

		if distance > fallbackDistance then
			fallbackPosition = candidate
			fallbackDistance = distance
		end
	end

	local centerDirection = Vector3.new(-rootPosition.X, 0, -rootPosition.Z)
	if centerDirection.Magnitude > 0 then
		local radius = WaveConfig.SpawnRadius + WaveConfig.SpawnRadiusJitter
		local candidate = createSpawnCandidate(rootPosition, math.atan2(centerDirection.Z, centerDirection.X), radius)
		if getFlatDistance(candidate, rootPosition) > fallbackDistance then
			return candidate
		end
	end

	return fallbackPosition or ArenaConfig.clampToArena(rootPosition, ArenaConfig.SpawnMargin)
end

local function spawnNearPlayer(player)
	local root = PlayerStateService.getRoot(player)
	if not root then
		return
	end

	EnemyService.spawn(chooseEnemyType(), getSpawnPosition(root.Position))
end

function WaveService.start()
	RunService.Heartbeat:Connect(function(deltaTime)
		if PlayerStateService.isPaused() then
			return
		end

		local alivePlayers = PlayerStateService.getAlivePlayers()
		if #alivePlayers == 0 then
			hadAlivePlayers = false
			return
		end

		if not hadAlivePlayers then
			elapsed = 0
			spawnAccumulator = 0
			hadAlivePlayers = true
		end

		elapsed += deltaTime
		spawnAccumulator += deltaTime

		if spawnAccumulator < getSpawnInterval() then
			return
		end

		spawnAccumulator = 0

		local maxEnemies = getMaxEnemies()
		if EnemyService.count() >= maxEnemies then
			return
		end

		for _ = 1, getEnemiesPerSpawn() do
			if EnemyService.count() >= maxEnemies then
				break
			end

			local player = alivePlayers[math.random(1, #alivePlayers)]
			spawnNearPlayer(player)
		end
	end)
end

return WaveService
