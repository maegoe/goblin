local WeaponDefinitions = {
	BasicBolt = {
		Damage = 18,
		AttackInterval = 1.05,
		Range = 48,
		ProjectileSpeed = 90,
		TargetingMode = "Nearest",
		ExplosionFeedbackImage = "rbxassetid://115292878237004",
		ExplosionFeedbackSprite = {
			Image = "rbxassetid://115637673020473",
			FrameSize = Vector2.new(128, 128),
			Columns = 8,
			FrameCount = 8,
		},
		ExplosionFeedbackDuration = 0.35,
	},
}

return WeaponDefinitions
