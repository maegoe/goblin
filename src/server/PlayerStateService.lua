local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local PlayerDefaults = require(Shared:WaitForChild("PlayerDefaults"))
local PersistentUpgradeDefinitions = require(Shared:WaitForChild("PersistentUpgradeDefinitions"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local UpgradeDefinitions = require(Shared:WaitForChild("UpgradeDefinitions"))

local MetaProgressionService = require(script.Parent:WaitForChild("MetaProgressionService"))
local RunResultService = require(script.Parent:WaitForChild("RunResultService"))
local EnemyService

local PlayerStateService = {}

local states = {}
local statsRemote
local choicesRemote
local startRunRemote
local statsAccumulator = 0
local LEVEL_UP_CHOICE_COUNT = 3
local DEFAULT_RARITY = "common"
local DEFAULT_RARITY_LABEL = "Common"
local DEFAULT_RARITY_COLOR = { 190, 198, 210 }

local function logState(player, message)
	print(string.format("[goblin][PlayerState] %s: %s", player.Name, message))
end

local function getRarityConfig()
	local rarityConfig = UpgradeDefinitions.Rarity
	if type(rarityConfig) ~= "table" then
		return {}
	end

	return rarityConfig
end

local function getExperienceToNextLevel(level)
	return PlayerDefaults.ExperienceToNextLevel + ((level - 1) * PlayerDefaults.ExperienceGrowth)
end

local function canOfferUpgrade(state, definition)
	if definition.EffectType == "Heal" then
		return state.Health < state.MaxHealth
	end

	if definition.MaxStacks then
		local currentStacks = state.Upgrades[definition.Id] or 0
		return currentStacks < definition.MaxStacks
	end

	return true
end

local function chooseRarity()
	local rarityConfig = getRarityConfig()
	local rarityOrder = rarityConfig.Order
	if type(rarityOrder) ~= "table" or #rarityOrder == 0 then
		return DEFAULT_RARITY
	end

	local rarityWeights = rarityConfig.Weights
	if type(rarityWeights) ~= "table" then
		rarityWeights = {}
	end
	local totalWeight = 0

	for _, rarity in ipairs(rarityOrder) do
		local weight = rarityWeights[rarity]
		if type(weight) == "number" and weight > 0 then
			totalWeight += weight
		end
	end

	if totalWeight <= 0 then
		return rarityOrder[1] or DEFAULT_RARITY
	end

	local roll = math.random() * totalWeight
	local cursor = 0
	for _, rarity in ipairs(rarityOrder) do
		local weight = rarityWeights[rarity]
		if type(weight) == "number" and weight > 0 then
			cursor += weight
		end
		if roll <= cursor then
			return rarity
		end
	end

	return rarityOrder[1] or DEFAULT_RARITY
end

local function getRarityDisplay(rarity)
	local rarityConfig = getRarityConfig()
	local displays = rarityConfig.Display
	if type(displays) ~= "table" then
		return DEFAULT_RARITY_LABEL, DEFAULT_RARITY_COLOR
	end

	local display = displays[rarity] or displays[DEFAULT_RARITY]
	if type(display) ~= "table" then
		return DEFAULT_RARITY_LABEL, DEFAULT_RARITY_COLOR
	end

	local label = display.Label
	if type(label) ~= "string" then
		label = DEFAULT_RARITY_LABEL
	end

	local color = display.Color
	if type(color) ~= "table" then
		color = DEFAULT_RARITY_COLOR
	end

	return label, color
end

local function isFiniteNumber(value)
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function requiresNumericValue(definition)
	return definition.EffectType == "IncreaseMaxHealth" or definition.EffectType == "Heal" or definition.StatKey ~= nil
end

local function getUpgradeValue(definition, rarity)
	if not isFiniteNumber(definition.Value) then
		return nil
	end

	local rarityConfig = getRarityConfig()
	local multipliers = rarityConfig.ValueMultipliers
	if type(multipliers) ~= "table" then
		multipliers = {}
	end
	local multiplier = multipliers[rarity]
	if not isFiniteNumber(multiplier) then
		multiplier = 1
	end

	local value = definition.Value * multiplier
	if not isFiniteNumber(value) then
		return nil
	end

	if value % 1 == 0 then
		return value
	end

	return math.floor((value * 100) + 0.5) / 100
end

local function formatSignedValue(value)
	local text
	if value % 1 == 0 then
		text = tostring(value)
	else
		text = string.format("%.2f", value):gsub("0+$", ""):gsub("%.$", "")
	end

	if value > 0 then
		return "+" .. text
	end

	return text
end

local function formatDescription(definition, value)
	if type(definition.DescriptionTemplate) == "string" then
		if not isFiniteNumber(value) then
			return nil
		end

		if definition.EffectType == "Heal" then
			return string.format(definition.DescriptionTemplate, tostring(math.abs(value)))
		end

		return string.format(definition.DescriptionTemplate, formatSignedValue(value))
	end

	if type(definition.Description) == "string" then
		return definition.Description
	end
	if type(definition.DisplayName) == "string" then
		return definition.DisplayName
	end
	if type(definition.Id) == "string" then
		return definition.Id
	end

	return nil
end

local function createUpgradeChoice(upgradeId)
	local definition = UpgradeDefinitions[upgradeId]
	if not definition then
		return nil
	end

	local choiceId = definition.Id or upgradeId
	if type(choiceId) ~= "string" then
		return nil
	end

	local rarity = chooseRarity()
	local rarityLabel, rarityColor = getRarityDisplay(rarity)
	local value = getUpgradeValue(definition, rarity)
	if requiresNumericValue(definition) and not isFiniteNumber(value) then
		return nil
	end

	local description = formatDescription(definition, value)
	if not description then
		return nil
	end

	return {
		id = choiceId,
		displayName = definition.DisplayName or choiceId,
		description = description,
		rarity = rarity,
		rarityLabel = rarityLabel,
		rarityColor = rarityColor,
		value = value,
	}
end

local function getRandomUpgradeChoices(state)
	local pool = {}
	local seenPoolIds = {}
	for _, upgradeId in ipairs(UpgradeDefinitions.Order) do
		local definition = UpgradeDefinitions[upgradeId]
		if definition and not seenPoolIds[upgradeId] and canOfferUpgrade(state, definition) then
			seenPoolIds[upgradeId] = true
			table.insert(pool, upgradeId)
		end
	end

	for index = #pool, 2, -1 do
		local swapIndex = math.random(index)
		pool[index], pool[swapIndex] = pool[swapIndex], pool[index]
	end

	local choices = {}
	local selectedIds = {}
	for _, upgradeId in ipairs(pool) do
		if #choices >= LEVEL_UP_CHOICE_COUNT then
			break
		end

		local choice = createUpgradeChoice(upgradeId)
		if choice and not selectedIds[choice.id] then
			selectedIds[choice.id] = true
			table.insert(choices, choice)
		end
	end

	return choices
end

local function getPersistentUpgradeLevel(snapshot, upgradeId)
	local upgrades = snapshot and snapshot.PersistentUpgrades
	if type(upgrades) ~= "table" then
		return 0
	end

	local level = upgrades[upgradeId]
	if type(level) ~= "number" then
		return 0
	end

	return math.max(0, math.floor(level))
end

local function getPersistentStatBonus(snapshot, statKey)
	local bonus = 0
	for _, upgradeId in ipairs(PersistentUpgradeDefinitions.Order) do
		local definition = PersistentUpgradeDefinitions[upgradeId]
		if definition and definition.StatKey == statKey then
			bonus += getPersistentUpgradeLevel(snapshot, upgradeId) * definition.ValuePerLevel
		end
	end

	return bonus
end

local function createState(player, runActive)
	local progression = MetaProgressionService.getSnapshot(player)
	local maxHealth = PlayerDefaults.MaxHealth + getPersistentStatBonus(progression, "MaxHealth")
	local attackDamage = PlayerDefaults.AttackDamage + getPersistentStatBonus(progression, "AttackDamage")

	return {
		MaxHealth = maxHealth,
		Health = maxHealth,
		MoveSpeed = PlayerDefaults.MoveSpeed,
		AttackDamage = attackDamage,
		AttackInterval = PlayerDefaults.AttackInterval,
		AttackRange = PlayerDefaults.AttackRange,
		Level = PlayerDefaults.StartLevel,
		Experience = PlayerDefaults.StartExperience,
		ExperienceToNextLevel = getExperienceToNextLevel(PlayerDefaults.StartLevel),
		SurvivalTime = 0,
		KillCount = 0,
		Alive = runActive == true,
		RunActive = runActive == true,
		PendingChoices = nil,
		Upgrades = {},
		ExplosiveBolt = nil,
	}
end

local function processLevelUps(player, state)
	while state.Experience >= state.ExperienceToNextLevel and not state.PendingChoices do
		state.Experience -= state.ExperienceToNextLevel
		state.Level += 1
		state.ExperienceToNextLevel = getExperienceToNextLevel(state.Level)
		PlayerStateService.setPendingChoices(player, getRandomUpgradeChoices(state))
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

	local previousHealth = state.Health
	state.Health = math.max(0, state.Health - amount)

	if state.Health <= 0 then
		state.Alive = false
		state.RunActive = false
		state.PendingChoices = nil
		logState(player, string.format(
			"defeated by game HP; damage=%s health=%s->0 survival=%.1f level=%d xp=%d. Roblox Humanoid death was not triggered.",
			tostring(amount),
			tostring(previousHealth),
			state.SurvivalTime,
			state.Level,
			state.Experience
		))
		RunResultService.endRun(player, state, "Defeat")
	end

	PlayerStateService.publish(player)
end

function PlayerStateService.startRun(player)
	local currentState = states[player]
	if currentState and currentState.RunActive then
		return false
	end

	if not EnemyService then
		EnemyService = require(script.Parent:WaitForChild("EnemyService"))
	end
	EnemyService.clear()

	states[player] = createState(player, true)
	PlayerStateService.applyMovement(player)
	PlayerStateService.publish(player)
	logState(player, string.format(
		"StartRun accepted; maxHealth=%d attackDamage=%d",
		states[player].MaxHealth,
		states[player].AttackDamage
	))

	return true
end

local function applyUpgradeDefinition(state, definition, value)
	if definition.EffectType == "IncreaseMaxHealth" then
		if not isFiniteNumber(value) or not isFiniteNumber(state.MaxHealth) or not isFiniteNumber(state.Health) then
			return false
		end

		state.MaxHealth += value
		state.Health = math.min(state.MaxHealth, state.Health + value)
		return true
	end

	if definition.EffectType == "Heal" then
		if not isFiniteNumber(value) or not isFiniteNumber(state.MaxHealth) or not isFiniteNumber(state.Health) then
			return false
		end

		state.Health = math.min(state.MaxHealth, state.Health + value)
		return true
	end

	if definition.EffectType == "EnableExplosiveBolt" then
		local currentStacks = state.Upgrades[definition.Id] or 0
		if not isFiniteNumber(currentStacks) then
			return false
		end

		if isFiniteNumber(definition.MaxStacks) and currentStacks >= definition.MaxStacks then
			return false
		end

		state.Upgrades[definition.Id] = currentStacks + 1
		state.ExplosiveBolt = {
			Radius = definition.ExplosionRadius,
			DamageMultiplier = definition.ExplosionDamageMultiplier,
		}
		return true
	end

	if not definition.StatKey then
		return false
	end

	if not isFiniteNumber(value) or not isFiniteNumber(state[definition.StatKey]) then
		return false
	end

	local nextValue = state[definition.StatKey] + value
	if isFiniteNumber(definition.MinValue) then
		nextValue = math.max(definition.MinValue, nextValue)
	end
	if isFiniteNumber(definition.MaxValue) then
		nextValue = math.min(definition.MaxValue, nextValue)
	end

	state[definition.StatKey] = nextValue
	return true
end

function PlayerStateService.setPendingChoices(player, choiceIds)
	local state = states[player]
	if not state or state.PendingChoices then
		return
	end

	state.PendingChoices = choiceIds

	local choices = {}
	for _, choice in ipairs(choiceIds) do
		local definition = UpgradeDefinitions[choice.id]
		if definition then
			table.insert(choices, {
				id = definition.Id,
				displayName = definition.DisplayName,
				description = choice.description,
				rarity = choice.rarity,
				rarityLabel = choice.rarityLabel,
				rarityColor = choice.rarityColor,
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

function PlayerStateService.recordKill(player)
	local state = states[player]
	if not state or not state.Alive then
		return
	end

	state.KillCount += 1
end

function PlayerStateService.applyUpgrade(player, upgradeId)
	local state = states[player]
	if not state or not state.PendingChoices then
		return false
	end

	local isAllowed = false
	local selectedChoice = nil
	for _, pendingChoice in ipairs(state.PendingChoices) do
		if pendingChoice.id == upgradeId then
			isAllowed = true
			selectedChoice = pendingChoice
			break
		end
	end

	local definition = UpgradeDefinitions[upgradeId]
	if not isAllowed or not definition then
		return false
	end

	if not applyUpgradeDefinition(state, definition, selectedChoice.value) then
		return false
	end

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

	logState(player, string.format(
		"CharacterAdded; runActive=%s alive=%s health=%s level=%s xp=%s",
		tostring(state.RunActive),
		tostring(state.Alive),
		tostring(state.Health),
		tostring(state.Level),
		tostring(state.Experience)
	))

	if not state.RunActive then
		state.Health = 0
		state.Alive = false
		state.PendingChoices = nil
		PlayerStateService.publish(player)
		logState(player, "CharacterAdded ignored because run is already defeated; combat state was not restarted.")
		return
	end

	state.Health = state.MaxHealth
	state.Alive = true
	state.PendingChoices = nil

	PlayerStateService.applyMovement(player)
	PlayerStateService.publish(player)
end

local function onPlayerAdded(player)
	states[player] = createState(player, false)

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
	startRunRemote = Remotes.get(Remotes.Names.StartRun)
	startRunRemote.OnServerEvent:Connect(function(player)
		PlayerStateService.startRun(player)
	end)

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
