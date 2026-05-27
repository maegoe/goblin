local WaveConfig = {
	EnemyType = "BasicSlime",
	TargetSessionSeconds = 600,
	InitialSpawnInterval = 2,
	MinimumSpawnInterval = 0.6,
	SpawnIntervalRampPerSecond = 0.0038,
	SpawnRadius = 72,
	SpawnRadiusJitter = 18,
	MaxEnemies = 76,
	EnemiesPerSpawn = 1,
	PressureStages = {
		{
			StartsAt = 0,
			EnemiesPerSpawn = 1,
			MaxEnemies = 22,
			EnemyWeights = {
				BasicSlime = 80,
				FastSlime = 20,
			},
		},
		{
			StartsAt = 60,
			EnemiesPerSpawn = 1,
			MaxEnemies = 28,
			EnemyWeights = {
				BasicSlime = 70,
				FastSlime = 25,
				TankSlime = 5,
			},
		},
		{
			StartsAt = 120,
			EnemiesPerSpawn = 2,
			MaxEnemies = 36,
			EnemyWeights = {
				BasicSlime = 60,
				FastSlime = 30,
				TankSlime = 10,
			},
		},
		{
			StartsAt = 210,
			EnemiesPerSpawn = 2,
			MaxEnemies = 46,
			EnemyWeights = {
				BasicSlime = 50,
				FastSlime = 35,
				TankSlime = 15,
			},
		},
		{
			StartsAt = 300,
			EnemiesPerSpawn = 3,
			MaxEnemies = 58,
			EnemyWeights = {
				BasicSlime = 45,
				FastSlime = 35,
				TankSlime = 20,
			},
		},
		{
			StartsAt = 420,
			EnemiesPerSpawn = 3,
			MaxEnemies = 68,
			EnemyWeights = {
				BasicSlime = 35,
				FastSlime = 35,
				TankSlime = 30,
			},
		},
		{
			StartsAt = 540,
			EnemiesPerSpawn = 4,
			MaxEnemies = 76,
			EnemyWeights = {
				BasicSlime = 25,
				FastSlime = 35,
				TankSlime = 40,
			},
		},
	},
}

return WaveConfig
