local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local WaveConfig = require(Shared:WaitForChild("WaveConfig"))

local EnemyService = require(script.Parent:WaitForChild("EnemyService"))
local PlayerStateService = require(script.Parent:WaitForChild("PlayerStateService"))

local WaveService = {}

local elapsed = 0
local spawnAccumulator = 0
local hadAlivePlayers = false

local function getSpawnInterval()
	return math.max(
		WaveConfig.MinimumSpawnInterval,
		WaveConfig.InitialSpawnInterval - (elapsed * WaveConfig.SpawnIntervalRampPerSecond)
	)
end

local function getEnemiesPerSpawn()
	return WaveConfig.EnemiesPerSpawn + math.floor(elapsed / WaveConfig.EnemiesPerSpawnEverySeconds)
end

local function spawnNearPlayer(player)
	local root = PlayerStateService.getRoot(player)
	if not root then
		return
	end

	local angle = math.random() * math.pi * 2
	local radius = WaveConfig.SpawnRadius + (math.random() * WaveConfig.SpawnRadiusJitter)
	local offset = Vector3.new(math.cos(angle) * radius, 2, math.sin(angle) * radius)

	EnemyService.spawn(WaveConfig.EnemyType, root.Position + offset)
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

		if EnemyService.count() >= WaveConfig.MaxEnemies then
			return
		end

		for _ = 1, getEnemiesPerSpawn() do
			if EnemyService.count() >= WaveConfig.MaxEnemies then
				break
			end

			local player = alivePlayers[math.random(1, #alivePlayers)]
			spawnNearPlayer(player)
		end
	end)
end

return WaveService
