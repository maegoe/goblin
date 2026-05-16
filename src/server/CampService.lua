local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local CampConfig = require(Shared:WaitForChild("CampConfig"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local MetaProgressionService = require(script.Parent:WaitForChild("MetaProgressionService"))

local CampService = {}

local purchaseCampLevelRemote

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
end

return CampService
