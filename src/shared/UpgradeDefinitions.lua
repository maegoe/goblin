local UpgradeDefinitions = {
	AttackDamageUp = {
		Id = "AttackDamageUp",
		DisplayName = "Attack Damage Up",
		Description = "+8 attack damage",
		StatKey = "AttackDamage",
		Value = 8,
		Stackable = true,
	},
	AttackSpeedUp = {
		Id = "AttackSpeedUp",
		DisplayName = "Attack Speed Up",
		Description = "-0.12s attack interval",
		StatKey = "AttackInterval",
		Value = -0.12,
		MinValue = 0.35,
		Stackable = true,
	},
	MoveSpeedUp = {
		Id = "MoveSpeedUp",
		DisplayName = "Move Speed Up",
		Description = "+2 movement speed",
		StatKey = "MoveSpeed",
		Value = 2,
		Stackable = true,
	},
}

UpgradeDefinitions.Order = {
	"AttackDamageUp",
	"AttackSpeedUp",
	"MoveSpeedUp",
}

return UpgradeDefinitions
