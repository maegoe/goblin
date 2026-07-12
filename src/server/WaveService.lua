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
local firedSwarmEvents = {}
local pendingSwarm = nil

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

local function getPositiveInteger(value, fallback)
	if type(value) ~= "number" then
		return fallback
	end

	return math.max(0, math.floor(value))
end

local function getPositiveNumber(value, fallback)
	if type(value) ~= "number" or value <= 0 then
		return fallback
	end

	return value
end

local function getMaxEnemies()
	local stage = getCurrentPressureStage()
	if stage and type(stage.MaxEnemies) == "number" then
		return stage.MaxEnemies
	end

	return WaveConfig.MaxEnemies
end

local function getSwarmMaxEnemies(eventConfig)
	local eventMaxEnemies = eventConfig and eventConfig.MaxConcurrentEnemies
	if type(eventMaxEnemies) == "number" then
		return math.min(getMaxEnemies(), eventMaxEnemies)
	end

	return getMaxEnemies()
end

local function chooseEnemyType(weightOverride)
	local stage = getCurrentPressureStage()
	local weights = weightOverride
	if type(weights) ~= "table" then
		weights = stage and stage.EnemyWeights
	end
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

local function spawnNearPlayer(player, swarmEvent)
	local root = PlayerStateService.getRoot(player)
	if not root then
		return
	end

	local enemy = EnemyService.spawn(chooseEnemyType(swarmEvent and swarmEvent.EnemyWeights), getSpawnPosition(root.Position), elapsed)
	if enemy and swarmEvent then
		enemy:SetAttribute("SpawnSource", "SwarmEvent")
		enemy:SetAttribute("SwarmEventId", swarmEvent.Id or "Swarm")
		enemy:SetAttribute("SwarmScheduledAt", swarmEvent.StartsAt or elapsed)
	end

	return enemy
end

local function resetSwarmState()
	firedSwarmEvents = {}
	pendingSwarm = nil
end

local function startDueSwarmEvent()
	if pendingSwarm then
		return
	end

	local swarmEvents = WaveConfig.SwarmEvents
	if type(swarmEvents) ~= "table" then
		return
	end

	for index, eventConfig in ipairs(swarmEvents) do
		if not firedSwarmEvents[index] and type(eventConfig.StartsAt) == "number" and elapsed >= eventConfig.StartsAt then
			firedSwarmEvents[index] = true

			local spawnCount = getPositiveInteger(eventConfig.SpawnCount, 0)
			if spawnCount > 0 then
				pendingSwarm = {
					Config = eventConfig,
					Remaining = spawnCount,
					Elapsed = 0,
					Accumulator = 0,
				}
			end

			return
		end
	end
end

local function processPendingSwarm(deltaTime, alivePlayers)
	if not pendingSwarm or #alivePlayers == 0 then
		return
	end

	local eventConfig = pendingSwarm.Config
	pendingSwarm.Elapsed += deltaTime
	pendingSwarm.Accumulator += deltaTime

	local expiresAfter = getPositiveNumber(eventConfig.ExpiresAfter, 8)
	if pendingSwarm.Elapsed >= expiresAfter then
		pendingSwarm = nil
		return
	end

	local burstInterval = getPositiveNumber(eventConfig.BurstInterval, 0.25)
	if pendingSwarm.Accumulator < burstInterval then
		return
	end

	pendingSwarm.Accumulator = 0

	local maxEnemies = getSwarmMaxEnemies(eventConfig)
	local burstSize = getPositiveInteger(eventConfig.BurstSize, 1)
	local spawned = 0

	while pendingSwarm and pendingSwarm.Remaining > 0 and spawned < burstSize do
		if EnemyService.count() >= maxEnemies then
			break
		end

		local player = alivePlayers[math.random(1, #alivePlayers)]
		if spawnNearPlayer(player, eventConfig) then
			pendingSwarm.Remaining -= 1
			spawned += 1
		else
			break
		end
	end

	if pendingSwarm and pendingSwarm.Remaining <= 0 then
		pendingSwarm = nil
	end
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
			resetSwarmState()
			hadAlivePlayers = true
		end

		elapsed += deltaTime
		spawnAccumulator += deltaTime
		startDueSwarmEvent()
		processPendingSwarm(deltaTime, alivePlayers)

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
