local WeaponDefinitions = {
	BaselineMelee = {
		Id = "BaselineMelee",
		DisplayName = "Training Slash",
		Type = "Melee",
		DamageMultiplier = 1,
		Range = 9,
		MaxTargets = 3,
		FeedbackColor = Color3.fromRGB(255, 238, 160),
		FeedbackDuration = 0.18,
	},
	BasicBolt = {
		Id = "BasicBolt",
		DisplayName = "Basic Bolt",
		Type = "Projectile",
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
