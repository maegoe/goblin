local MAX_HEALTH_COSTS = { 10, 15, 25, 40, 60, 85, 115, 150, 190, 235 }
local ATTACK_DAMAGE_COSTS = { 10, 15, 25, 40, 60, 85, 115, 150, 190, 235 }
local MAX_UPGRADE_LEVEL = 50
local LEVELS_PER_CAMP_LEVEL = 5
local FORMULA_LINEAR_STEP = 45
local FORMULA_TRIANGULAR_STEP = 5
local PERMANENT_GROWTH_VALUE_SCALAR = 1.011

local function getAdjustedValuePerLevel(baseValue)
	return math.floor((baseValue * PERMANENT_GROWTH_VALUE_SCALAR * 1000) + 0.5) / 1000
end

local function getGeneratedCost(baseCosts, level)
	local baseLevel = #baseCosts
	if level <= baseLevel then
		return baseCosts[level]
	end

	local extraLevel = level - baseLevel
	local triangular = (extraLevel - 1) * extraLevel / 2

	local cost = baseCosts[baseLevel] + (extraLevel * FORMULA_LINEAR_STEP) + (triangular * FORMULA_TRIANGULAR_STEP)
	return math.floor(cost + 0.5)
end

local function buildCosts(baseCosts)
	local costs = {}
	for level = 1, MAX_UPGRADE_LEVEL do
		costs[level] = getGeneratedCost(baseCosts, level)
	end

	return costs
end

local GENERATED_MAX_HEALTH_COSTS = buildCosts(MAX_HEALTH_COSTS)
local GENERATED_ATTACK_DAMAGE_COSTS = buildCosts(ATTACK_DAMAGE_COSTS)

local PersistentUpgradeDefinitions = {
	MaxHealth = {
		Id = "MaxHealth",
		DisplayNameKey = "persistent.maxHealth",
		StatKey = "MaxHealth",
		BaseValuePerLevel = 5,
		ValueScalar = PERMANENT_GROWTH_VALUE_SCALAR,
		ValuePerLevel = getAdjustedValuePerLevel(5),
		MaxLevel = #GENERATED_MAX_HEALTH_COSTS,
		Costs = GENERATED_MAX_HEALTH_COSTS,
		CostFormula = "Levels 1-10 use base costs; levels 11-50 use base[10] + extra*45 + triangular(extra-1)*5.",
	},
	AttackDamage = {
		Id = "AttackDamage",
		DisplayNameKey = "persistent.attackDamage",
		StatKey = "AttackDamage",
		BaseValuePerLevel = 1,
		ValueScalar = PERMANENT_GROWTH_VALUE_SCALAR,
		ValuePerLevel = getAdjustedValuePerLevel(1),
		MaxLevel = #GENERATED_ATTACK_DAMAGE_COSTS,
		Costs = GENERATED_ATTACK_DAMAGE_COSTS,
		CostFormula = "Levels 1-10 use base costs; levels 11-50 use base[10] + extra*45 + triangular(extra-1)*5.",
	},
}

PersistentUpgradeDefinitions.Order = {
	"MaxHealth",
	"AttackDamage",
}

PersistentUpgradeDefinitions.LevelsPerCampLevel = LEVELS_PER_CAMP_LEVEL
PersistentUpgradeDefinitions.MaxUpgradeLevel = MAX_UPGRADE_LEVEL

function PersistentUpgradeDefinitions.getCampLevelCap(campLevel)
	if type(campLevel) ~= "number" or campLevel ~= campLevel or campLevel == math.huge or campLevel == -math.huge then
		campLevel = 0
	end

	local cap = math.floor(campLevel) * LEVELS_PER_CAMP_LEVEL
	return math.max(0, math.min(MAX_UPGRADE_LEVEL, cap))
end

return PersistentUpgradeDefinitions
