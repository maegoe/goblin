local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GoblinAppearanceStages = require(Shared:WaitForChild("GoblinAppearanceStages"))
local MetaProgressionDefaults = require(Shared:WaitForChild("MetaProgressionDefaults"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local MetaProgressionService = {}

local DATASTORE_NAME = "GoblinMetaProgressionV1"
local KEY_PREFIX = "player:"

local dataStore
local progressionRemote
local sessions = {}
local memoryFallback = {}
local started = false
local hasLoggedStudioFallback = false

local function cloneValue(value)
	if type(value) ~= "table" then
		return value
	end

	local copy = {}
	for key, childValue in pairs(value) do
		copy[key] = cloneValue(childValue)
	end

	return copy
end

local function asNonNegativeInteger(value, fallback)
	if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
		return fallback
	end

	return math.max(0, math.floor(value))
end

local function normalizeStringArray(value)
	local result = {}
	local seen = {}
	if type(value) ~= "table" then
		return result
	end

	for _, item in ipairs(value) do
		if type(item) == "string" and not seen[item] then
			seen[item] = true
			table.insert(result, item)
		end
	end

	return result
end

local function normalizePersistentUpgrades(value)
	local defaults = MetaProgressionDefaults.PersistentUpgrades
	local upgrades = {}
	if type(value) ~= "table" then
		value = {}
	end

	for upgradeKey, defaultValue in pairs(defaults) do
		upgrades[upgradeKey] = asNonNegativeInteger(value[upgradeKey], defaultValue)
	end

	return upgrades
end

local function normalizeSnapshot(value)
	if type(value) ~= "table" then
		value = {}
	end

	local snapshot = MetaProgressionDefaults.create()
	snapshot.SchemaVersion = asNonNegativeInteger(value.SchemaVersion, MetaProgressionDefaults.SchemaVersion)
	snapshot.GrowthStones = asNonNegativeInteger(value.GrowthStones, MetaProgressionDefaults.GrowthStones)
	snapshot.CampMaterials = asNonNegativeInteger(value.CampMaterials, MetaProgressionDefaults.CampMaterials)
	snapshot.PersistentUpgrades = normalizePersistentUpgrades(value.PersistentUpgrades)
	snapshot.CampLevel = asNonNegativeInteger(value.CampLevel, MetaProgressionDefaults.CampLevel)
	snapshot.OwnedArtifacts = normalizeStringArray(value.OwnedArtifacts)

	if type(value.EquippedArtifactId) == "string" then
		snapshot.EquippedArtifactId = value.EquippedArtifactId
	end

	return snapshot
end

local function getDataStoreKey(player)
	return KEY_PREFIX .. tostring(player.UserId)
end

local function initializeDataStore()
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(DATASTORE_NAME)
	end)

	if ok then
		dataStore = result
	else
		dataStore = nil
		warn("[goblin] MetaProgression DataStore unavailable, using memory fallback: " .. tostring(result))
	end
end

local function publish(player)
	local session = sessions[player]
	if not session or not progressionRemote then
		return
	end

	progressionRemote:FireClient(player, {
		snapshot = cloneValue(session.snapshot),
		appearanceStage = cloneValue(GoblinAppearanceStages.getStageForSnapshot(session.snapshot)),
		storageMode = session.storageMode,
	})
end

local function createPayload(player)
	local session = sessions[player]
	if not session then
		return nil
	end

	return {
		snapshot = cloneValue(session.snapshot),
		appearanceStage = cloneValue(GoblinAppearanceStages.getStageForSnapshot(session.snapshot)),
		storageMode = session.storageMode,
	}
end

local function saveSession(player)
	local session = sessions[player]
	if not session then
		return false
	end

	local snapshot = normalizeSnapshot(session.snapshot)
	session.snapshot = snapshot
	memoryFallback[player.UserId] = cloneValue(snapshot)

	if not dataStore then
		session.storageMode = "MemoryFallback"
		return true
	end

	local key = getDataStoreKey(player)
	local ok, err = pcall(function()
		dataStore:SetAsync(key, snapshot)
	end)

	if not ok then
		session.storageMode = "MemoryFallback"
		session.lastError = tostring(err)
		warn("[goblin] MetaProgression save failed, using memory fallback: " .. tostring(err))
		return false
	end

	session.storageMode = "DataStore"
	session.lastError = nil
	return true
end

local function loadSnapshot(player)
	local cached = memoryFallback[player.UserId]
	if cached then
		return normalizeSnapshot(cached), "MemoryFallback", nil
	end

	if not dataStore then
		return MetaProgressionDefaults.create(), "MemoryFallback", nil
	end

	local key = getDataStoreKey(player)
	local ok, result = pcall(function()
		return dataStore:GetAsync(key)
	end)

	if not ok then
		if RunService:IsStudio() and not hasLoggedStudioFallback then
			hasLoggedStudioFallback = true
			print("[goblin] MetaProgression using memory fallback because Studio API Services are unavailable.")
		elseif not RunService:IsStudio() then
			warn("[goblin] MetaProgression load failed, using memory fallback: " .. tostring(result))
		end

		dataStore = nil
		return MetaProgressionDefaults.create(), "MemoryFallback", tostring(result)
	end

	return normalizeSnapshot(result), "DataStore", nil
end

local function onPlayerAdded(player)
	local snapshot, storageMode, lastError = loadSnapshot(player)
	sessions[player] = {
		snapshot = snapshot,
		storageMode = storageMode,
		lastError = lastError,
	}

	memoryFallback[player.UserId] = cloneValue(snapshot)
	publish(player)
end

local function onPlayerRemoving(player)
	saveSession(player)
	sessions[player] = nil
end

function MetaProgressionService.getSnapshot(player)
	local session = sessions[player]
	if not session then
		return nil
	end

	return cloneValue(session.snapshot)
end

function MetaProgressionService.getStorageMode(player)
	local session = sessions[player]
	if not session then
		return nil
	end

	return session.storageMode
end

function MetaProgressionService.update(player, mutator)
	local session = sessions[player]
	if not session or type(mutator) ~= "function" then
		return false, nil
	end

	local nextSnapshot = cloneValue(session.snapshot)
	local ok, result = pcall(mutator, nextSnapshot)
	if not ok or result == false then
		return false, cloneValue(session.snapshot)
	end

	session.snapshot = normalizeSnapshot(nextSnapshot)
	local saved = saveSession(player)
	publish(player)

	return saved, cloneValue(session.snapshot)
end

function MetaProgressionService.start()
	if started then
		return
	end
	started = true

	progressionRemote = Remotes.get(Remotes.Names.MetaProgressionChanged)
	Remotes.get(Remotes.FunctionNames.GetMetaProgressionSnapshot).OnServerInvoke = function(player)
		return createPayload(player)
	end
	initializeDataStore()

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end
end

return MetaProgressionService
