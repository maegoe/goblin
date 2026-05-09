local UpgradeDefinitions = {
	Rarity = {
		Order = {
			"common",
			"rare",
			"epic",
			"legend",
		},
		Weights = {
			common = 70,
			rare = 20,
			epic = 8,
			legend = 2,
		},
		ValueMultipliers = {
			common = 1,
			rare = 1.5,
			epic = 2,
			legend = 3,
		},
		Display = {
			common = {
				Label = "Common",
				Color = { 190, 198, 210 },
			},
			rare = {
				Label = "Rare",
				Color = { 86, 170, 255 },
			},
			epic = {
				Label = "Epic",
				Color = { 188, 116, 255 },
			},
			legend = {
				Label = "Legend",
				Color = { 255, 196, 64 },
			},
		},
	},
	AttackDamageUp = {
		Id = "AttackDamageUp",
		DisplayName = "Attack Damage Up",
		DescriptionTemplate = "%s attack damage",
		Category = "Attack",
		StatKey = "AttackDamage",
		Value = 8,
		Stackable = true,
	},
	AttackSpeedUp = {
		Id = "AttackSpeedUp",
		DisplayName = "Attack Speed Up",
		DescriptionTemplate = "%ss attack interval",
		Category = "Attack",
		StatKey = "AttackInterval",
		Value = -0.12,
		MinValue = 0.35,
		Stackable = true,
	},
	MoveSpeedUp = {
		Id = "MoveSpeedUp",
		DisplayName = "Move Speed Up",
		DescriptionTemplate = "%s movement speed",
		Category = "Move",
		StatKey = "MoveSpeed",
		Value = 2,
		Stackable = true,
	},
	MaxHealthUp = {
		Id = "MaxHealthUp",
		DisplayName = "Max Health Up",
		DescriptionTemplate = "%s max health",
		Category = "Survival",
		EffectType = "IncreaseMaxHealth",
		Value = 20,
		Stackable = true,
	},
	QuickRecovery = {
		Id = "QuickRecovery",
		DisplayName = "Quick Recovery",
		DescriptionTemplate = "Recover %s health",
		Category = "Survival",
		EffectType = "Heal",
		Value = 30,
		Stackable = true,
	},
}

UpgradeDefinitions.Order = {
	"AttackDamageUp",
	"AttackSpeedUp",
	"MoveSpeedUp",
	"MaxHealthUp",
	"QuickRecovery",
}

return UpgradeDefinitions
