local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local CampConfig = require(Shared:WaitForChild("CampConfig"))
local CampExchangeConfig = require(Shared:WaitForChild("CampExchangeConfig"))
local FeedbackEvents = require(Shared:WaitForChild("FeedbackEvents"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local FeedbackService = require(script.Parent:WaitForChild("FeedbackService"))
local MetaProgressionService = require(script.Parent:WaitForChild("MetaProgressionService"))

local CampService = {}

local purchaseCampLevelRemote
local exchangeCampMaterialsRemote

local function getCampLevelCost(currentLevel)
	local nextLevel = currentLevel + 1
	if nextLevel > CampConfig.MaxLevel then
		return nil
	end

	return CampConfig.LevelCosts[nextLevel]
end

function CampService.purchaseCampLevel(player)
	local snapshot = MetaProgressionService.getSnapshot(player)
	if not snapshot then
		return false, "NoProgression"
	end

	local currentLevel = math.max(0, math.floor(snapshot.CampLevel or 0))
	local cost = getCampLevelCost(currentLevel)
	if not cost then
		return false, "MaxLevel"
	end
	if snapshot.CampMaterials < cost then
		return false, "NotEnoughCampMaterials"
	end

	local saved = MetaProgressionService.update(player, function(progression)
		local verifiedLevel = math.max(0, math.floor(progression.CampLevel or 0))
		local verifiedCost = getCampLevelCost(verifiedLevel)
		if not verifiedCost or progression.CampMaterials < verifiedCost then
			return false
		end

		progression.CampMaterials -= verifiedCost
		progression.CampLevel = verifiedLevel + 1
	end)

	if not saved then
		return false, "SaveFallbackOrRejected"
	end

	print(string.format(
		"[goblin][Camp] %s purchased camp level %d for %d CampMaterials",
		player.Name,
		currentLevel + 1,
		cost
	))
	FeedbackService.play(player, FeedbackEvents.CampPurchase)

	return true, nil
end

function CampService.exchangeCampMaterials(player, tierId)
	local exchange = CampExchangeConfig[tierId]
	if not exchange then
		return false, "UnknownExchange"
	end

	local snapshot = MetaProgressionService.getSnapshot(player)
	if not snapshot then
		return false, "NoProgression"
	end
	if snapshot.CampMaterials < exchange.CampMaterialCost then
		return false, "NotEnoughCampMaterials"
	end

	local saved = MetaProgressionService.update(player, function(progression)
		local verifiedExchange = CampExchangeConfig[tierId]
		if not verifiedExchange or progression.CampMaterials < verifiedExchange.CampMaterialCost then
			return false
		end

		progression.CampMaterials -= verifiedExchange.CampMaterialCost
		progression.GrowthStones += verifiedExchange.GrowthStoneReward
	end)

	if not saved then
		return false, "SaveFallbackOrRejected"
	end

	print(string.format(
		"[goblin][Camp] %s exchanged %d CampMaterials for %d GrowthStones",
		player.Name,
		exchange.CampMaterialCost,
		exchange.GrowthStoneReward
	))

	return true, nil
end

function CampService.start()
	purchaseCampLevelRemote = Remotes.get(Remotes.Names.PurchaseCampLevel)
	purchaseCampLevelRemote.OnServerEvent:Connect(function(player)
		local ok, reason = CampService.purchaseCampLevel(player)
		if not ok then
			print(string.format("[goblin][Camp] rejected camp level purchase for %s: %s", player.Name, tostring(reason)))
		end
	end)

	exchangeCampMaterialsRemote = Remotes.get(Remotes.Names.ExchangeCampMaterials)
	exchangeCampMaterialsRemote.OnServerEvent:Connect(function(player, tierId)
		if typeof(tierId) ~= "string" then
			return
		end

		local ok, reason = CampService.exchangeCampMaterials(player, tierId)
		if not ok then
			print(string.format(
				"[goblin][Camp] rejected material exchange %s for %s: %s",
				tostring(tierId),
				player.Name,
				tostring(reason)
			))
		end
	end)
end

return CampService
