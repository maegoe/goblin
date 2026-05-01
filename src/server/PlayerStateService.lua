local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local PlayerDefaults = require(Shared:WaitForChild("PlayerDefaults"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local UpgradeDefinitions = require(Shared:WaitForChild("UpgradeDefinitions"))

local PlayerStateService = {}

local states = {}
local statsRemote
local choicesRemote
local statsAccumulator = 0

local function getExperienceToNextLevel(level)
	return PlayerDefaults.ExperienceToNextLevel + ((level - 1) * PlayerDefaults.ExperienceGrowth)
end

local function createState()
	return {
		MaxHealth = PlayerDefaults.MaxHealth,
		Health = PlayerDefaults.MaxHealth,
		MoveSpeed = PlayerDefaults.MoveSpeed,
		AttackDamage = PlayerDefaults.AttackDamage,
		AttackInterval = PlayerDefaults.AttackInterval,
		AttackRange = PlayerDefaults.AttackRange,
		Level = PlayerDefaults.StartLevel,
		Experience = PlayerDefaults.StartExperience,
		ExperienceToNextLevel = getExperienceToNextLevel(PlayerDefaults.StartLevel),
		SurvivalTime = 0,
		Alive = true,
		PendingChoices = nil,
	}
end

local function processLevelUps(player, state)
	while state.Experience >= state.ExperienceToNextLevel and not state.PendingChoices do
		state.Experience -= state.ExperienceToNextLevel
		state.Level += 1
		state.ExperienceToNextLevel = getExperienceToNextLevel(state.Level)
		PlayerStateService.setPendingChoices(player, UpgradeDefinitions.Order)
	end
end

local function getHumanoid(player)
	local character = player.Character
	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

function PlayerStateService.applyMovement(player)
	local state = states[player]
	local humanoid = getHumanoid(player)
	if state and humanoid then
		humanoid.WalkSpeed = state.MoveSpeed
	end
end

function PlayerStateService.publish(player)
	local state = states[player]
	if not state or not statsRemote then
		return
	end

	statsRemote:FireClient(player, {
		health = state.Health,
		maxHealth = state.MaxHealth,
		level = state.Level,
		experience = state.Experience,
		experienceToNextLevel = state.ExperienceToNextLevel,
		survivalTime = state.SurvivalTime,
		alive = state.Alive,
	})
end

function PlayerStateService.getState(player)
	return states[player]
end

function PlayerStateService.getRoot(player)
	local character = player.Character
	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

function PlayerStateService.getAlivePlayers()
	local alivePlayers = {}

	for player, state in pairs(states) do
		if state.Alive and player.Parent == Players and PlayerStateService.getRoot(player) then
			table.insert(alivePlayers, player)
		end
	end

	return alivePlayers
end

function PlayerStateService.isPaused()
	for _, state in pairs(states) do
		if state.PendingChoices then
			return true
		end
	end

	return false
end

function PlayerStateService.damagePlayer(player, amount)
	local state = states[player]
	if not state or not state.Alive then
		return
	end

	state.Health = math.max(0, state.Health - amount)

	if state.Health <= 0 then
		state.Alive = false
		local humanoid = getHumanoid(player)
		if humanoid then
			humanoid.Health = 0
		end
	end

	PlayerStateService.publish(player)
end

function PlayerStateService.setPendingChoices(player, choiceIds)
	local state = states[player]
	if not state or state.PendingChoices then
		return
	end

	state.PendingChoices = choiceIds

	local choices = {}
	for _, choiceId in ipairs(choiceIds) do
		local definition = UpgradeDefinitions[choiceId]
		if definition then
			table.insert(choices, {
				id = definition.Id,
				displayName = definition.DisplayName,
				description = definition.Description,
			})
		end
	end

	choicesRemote:FireClient(player, choices)
end

function PlayerStateService.addExperience(player, amount)
	local state = states[player]
	if not state or not state.Alive then
		return
	end

	state.Experience += amount
	processLevelUps(player, state)

	PlayerStateService.publish(player)
end

function PlayerStateService.applyUpgrade(player, upgradeId)
	local state = states[player]
	if not state or not state.PendingChoices then
		return false
	end

	local isAllowed = false
	for _, pendingId in ipairs(state.PendingChoices) do
		if pendingId == upgradeId then
			isAllowed = true
			break
		end
	end

	local definition = UpgradeDefinitions[upgradeId]
	if not isAllowed or not definition then
		return false
	end

	local nextValue = state[definition.StatKey] + definition.Value
	if definition.MinValue then
		nextValue = math.max(definition.MinValue, nextValue)
	end

	state[definition.StatKey] = nextValue
	state.PendingChoices = nil
	processLevelUps(player, state)

	PlayerStateService.applyMovement(player)
	PlayerStateService.publish(player)

	return true
end

local function onCharacterAdded(player)
	local state = states[player]
	if not state then
		return
	end

	state.Health = state.MaxHealth
	state.Alive = true
	state.PendingChoices = nil

	PlayerStateService.applyMovement(player)
	PlayerStateService.publish(player)
end

local function onPlayerAdded(player)
	states[player] = createState()

	player.CharacterAdded:Connect(function()
		onCharacterAdded(player)
	end)

	if player.Character then
		onCharacterAdded(player)
	end
end

function PlayerStateService.start()
	statsRemote = Remotes.get(Remotes.Names.PlayerStatsChanged)
	choicesRemote = Remotes.get(Remotes.Names.LevelUpChoices)

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(function(player)
		states[player] = nil
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end

	RunService.Heartbeat:Connect(function(deltaTime)
		statsAccumulator += deltaTime

		for player, state in pairs(states) do
			if state.Alive and not state.PendingChoices then
				state.SurvivalTime += deltaTime
			end
		end

		if statsAccumulator >= 0.25 then
			statsAccumulator = 0
			for player in pairs(states) do
				PlayerStateService.publish(player)
			end
		end
	end)
end

return PlayerStateService
