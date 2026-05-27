local MetaProgressionDefaults = {
	SchemaVersion = 1,
	GrowthStones = 0,
	CampMaterials = 0,
	PersistentUpgrades = {
		MaxHealth = 0,
		AttackDamage = 0,
	},
	CampLevel = 0,
	OwnedArtifacts = {},
	EquippedArtifactId = nil,
}

function MetaProgressionDefaults.create()
	return {
		SchemaVersion = MetaProgressionDefaults.SchemaVersion,
		GrowthStones = MetaProgressionDefaults.GrowthStones,
		CampMaterials = MetaProgressionDefaults.CampMaterials,
		PersistentUpgrades = {
			MaxHealth = MetaProgressionDefaults.PersistentUpgrades.MaxHealth,
			AttackDamage = MetaProgressionDefaults.PersistentUpgrades.AttackDamage,
		},
		CampLevel = MetaProgressionDefaults.CampLevel,
		OwnedArtifacts = {},
		EquippedArtifactId = MetaProgressionDefaults.EquippedArtifactId,
	}
end

return MetaProgressionDefaults
