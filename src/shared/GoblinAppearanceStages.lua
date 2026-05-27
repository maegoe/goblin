local Assets = require(script.Parent:WaitForChild("Assets"))

local GoblinAppearanceStages = {}

GoblinAppearanceStages.Stages = {
	{
		Stage = 0,
		RequiredTotalPersistentUpgradeLevel = 0,
		DisplayNameKey = "appearance.sproutGoblin",
		DisplayName = "Sprout Goblin",
		Color = Color3.fromRGB(86, 154, 84),
		BadgeAssetId = Assets.v0_4.camp_ui.badge_goblin_growth_0_256x256,
	},
	{
		Stage = 1,
		RequiredTotalPersistentUpgradeLevel = 2,
		DisplayNameKey = "appearance.trainedGoblin",
		DisplayName = "Trained Goblin",
		Color = Color3.fromRGB(104, 184, 100),
		BadgeAssetId = Assets.v0_4.camp_ui.badge_goblin_growth_1_256x256,
	},
	{
		Stage = 2,
		RequiredTotalPersistentUpgradeLevel = 5,
		DisplayNameKey = "appearance.veteranGoblin",
		DisplayName = "Veteran Goblin",
		Color = Color3.fromRGB(139, 211, 112),
		BadgeAssetId = Assets.v0_4.camp_ui.badge_goblin_growth_2_256x256,
	},
}

local function getPersistentUpgradeTotal(snapshot)
	local upgrades = snapshot and snapshot.PersistentUpgrades
	if type(upgrades) ~= "table" then
		return 0
	end

	local total = 0
	for _, level in pairs(upgrades) do
		if type(level) == "number" and level == level and level ~= math.huge and level ~= -math.huge then
			total += math.max(0, math.floor(level))
		end
	end

	return total
end

function GoblinAppearanceStages.getStageForSnapshot(snapshot)
	local totalLevel = getPersistentUpgradeTotal(snapshot)
	local selected = GoblinAppearanceStages.Stages[1]

	for _, stage in ipairs(GoblinAppearanceStages.Stages) do
		if totalLevel >= stage.RequiredTotalPersistentUpgradeLevel then
			selected = stage
		end
	end

	return {
		Stage = selected.Stage,
		RequiredTotalPersistentUpgradeLevel = selected.RequiredTotalPersistentUpgradeLevel,
		DisplayNameKey = selected.DisplayNameKey,
		DisplayName = selected.DisplayName,
		Color = selected.Color,
		BadgeAssetId = selected.BadgeAssetId,
		TotalPersistentUpgradeLevel = totalLevel,
	}
end

return GoblinAppearanceStages
