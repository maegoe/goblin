local EnemyDefinitions = {
	BasicSlime = {
		DisplayName = "Basic Slime",
		MaxHealth = 55,
		MoveSpeed = 10.5,
		ContactDamage = 8,
		ContactInterval = 0.8,
		ExperienceReward = 10,
		Size = Vector3.new(4, 4, 4),
		SpriteSize = Vector2.new(136, 136),
		SpriteColor = Color3.fromRGB(255, 255, 255),
	},
	FastSlime = {
		DisplayName = "Fast Slime",
		MaxHealth = 36,
		MoveSpeed = 20,
		ContactDamage = 6,
		ContactInterval = 0.65,
		ExperienceReward = 8,
		Size = Vector3.new(3.2, 3.2, 3.2),
		SpriteSize = Vector2.new(116, 116),
		SpriteColor = Color3.fromRGB(150, 220, 255),
	},
	TankSlime = {
		DisplayName = "Tank Slime",
		MaxHealth = 165,
		MoveSpeed = 8,
		ContactDamage = 14,
		ContactInterval = 1.05,
		ExperienceReward = 22,
		Size = Vector3.new(5.4, 5.4, 5.4),
		SpriteSize = Vector2.new(172, 172),
		SpriteColor = Color3.fromRGB(255, 185, 110),
	},
}

return EnemyDefinitions
