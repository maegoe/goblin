local CampExchangeConfig = {
	small = {
		Id = "small",
		CampMaterialCost = 1000,
		GrowthStoneReward = 2000,
		ButtonText = "1,000 MAT -> 2,000 STONE",
		DisabledText = "Need 1,000 MAT",
	},
	large = {
		Id = "large",
		CampMaterialCost = 10000,
		GrowthStoneReward = 25000,
		ButtonText = "10,000 MAT -> 25,000 STONE",
		DisabledText = "Need 10,000 MAT",
	},
}

CampExchangeConfig.Order = {
	"small",
	"large",
}

return CampExchangeConfig
