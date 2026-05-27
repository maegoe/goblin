local PersistentUpgradeDefinitions = {
	MaxHealth = {
		Id = "MaxHealth",
		DisplayNameKey = "persistent.maxHealth",
		StatKey = "MaxHealth",
		ValuePerLevel = 5,
		MaxLevel = 5,
		Costs = { 10, 15, 25, 40, 60 },
	},
	AttackDamage = {
		Id = "AttackDamage",
		DisplayNameKey = "persistent.attackDamage",
		StatKey = "AttackDamage",
		ValuePerLevel = 1,
		MaxLevel = 5,
		Costs = { 10, 15, 25, 40, 60 },
	},
}

PersistentUpgradeDefinitions.Order = {
	"MaxHealth",
	"AttackDamage",
}

return PersistentUpgradeDefinitions
