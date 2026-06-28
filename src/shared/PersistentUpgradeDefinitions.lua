local MAX_HEALTH_COSTS = { 10, 15, 25, 40, 60, 85, 115, 150, 190, 235 }
local ATTACK_DAMAGE_COSTS = { 10, 15, 25, 40, 60, 85, 115, 150, 190, 235 }

local PersistentUpgradeDefinitions = {
	MaxHealth = {
		Id = "MaxHealth",
		DisplayNameKey = "persistent.maxHealth",
		StatKey = "MaxHealth",
		ValuePerLevel = 5,
		MaxLevel = #MAX_HEALTH_COSTS,
		Costs = MAX_HEALTH_COSTS,
	},
	AttackDamage = {
		Id = "AttackDamage",
		DisplayNameKey = "persistent.attackDamage",
		StatKey = "AttackDamage",
		ValuePerLevel = 1,
		MaxLevel = #ATTACK_DAMAGE_COSTS,
		Costs = ATTACK_DAMAGE_COSTS,
	},
}

PersistentUpgradeDefinitions.Order = {
	"MaxHealth",
	"AttackDamage",
}

return PersistentUpgradeDefinitions
