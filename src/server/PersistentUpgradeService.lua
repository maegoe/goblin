local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local PersistentUpgradeDefinitions = require(Shared:WaitForChild("PersistentUpgradeDefinitions"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local MetaProgressionService = require(script.Parent:WaitForChild("MetaProgressionService"))

local PersistentUpgradeService = {}

local purchaseRemote

local function getCurrentLevel(snapshot, upgradeId)
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

local function getCost(definition, currentLevel)
	local nextLevel = currentLevel + 1
	if nextLevel > definition.MaxLevel then
		return nil
	end

	return definition.Costs[nextLevel]
end

function PersistentUpgradeService.purchase(player, upgradeId)
	local definition = PersistentUpgradeDefinitions[upgradeId]
	if not definition then
		return false, "UnknownUpgrade"
	end

	local snapshot = MetaProgressionService.getSnapshot(player)
	if not snapshot then
		return false, "NoProgression"
	end

	local currentLevel = getCurrentLevel(snapshot, upgradeId)
	local cost = getCost(definition, currentLevel)
	if not cost then
		return false, "MaxLevel"
	end
	if snapshot.GrowthStones < cost then
		return false, "NotEnoughGrowthStones"
	end

	local saved = MetaProgressionService.update(player, function(progression)
		local verifiedLevel = getCurrentLevel(progression, upgradeId)
		local verifiedCost = getCost(definition, verifiedLevel)
		if not verifiedCost or progression.GrowthStones < verifiedCost then
			return false
		end

		progression.GrowthStones -= verifiedCost
		progression.PersistentUpgrades[upgradeId] = verifiedLevel + 1
	end)

	if not saved then
		return false, "SaveFallbackOrRejected"
	end

	print(string.format(
		"[goblin][PersistentUpgrade] %s purchased %s level %d for %d GrowthStones",
		player.Name,
		upgradeId,
		currentLevel + 1,
		cost
	))

	return true, nil
end

function PersistentUpgradeService.start()
	purchaseRemote = Remotes.get(Remotes.Names.PurchasePersistentUpgrade)
	purchaseRemote.OnServerEvent:Connect(function(player, upgradeId)
		if typeof(upgradeId) ~= "string" then
			return
		end

		local ok, reason = PersistentUpgradeService.purchase(player, upgradeId)
		if not ok then
			print(string.format(
				"[goblin][PersistentUpgrade] rejected %s for %s: %s",
				tostring(upgradeId),
				player.Name,
				tostring(reason)
			))
		end
	end)
end

return PersistentUpgradeService
