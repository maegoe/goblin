local ArtifactDefinitions = require(script.Parent:WaitForChild("ArtifactDefinitions"))

local MetaProgressionDefaults = {
	SchemaVersion = 1,
	GrowthStones = 0,
	CampMaterials = 0,
	PersistentUpgrades = {
		MaxHealth = 0,
		AttackDamage = 0,
	},
	CampLevel = 0,
	OwnedArtifacts = ArtifactDefinitions.DefaultOwned,
	EquippedArtifactId = nil,
}

function MetaProgressionDefaults.create()
	local ownedArtifacts = {}
	for _, artifactId in ipairs(MetaProgressionDefaults.OwnedArtifacts) do
		table.insert(ownedArtifacts, artifactId)
	end

	return {
		SchemaVersion = MetaProgressionDefaults.SchemaVersion,
		GrowthStones = MetaProgressionDefaults.GrowthStones,
		CampMaterials = MetaProgressionDefaults.CampMaterials,
		PersistentUpgrades = {
			MaxHealth = MetaProgressionDefaults.PersistentUpgrades.MaxHealth,
			AttackDamage = MetaProgressionDefaults.PersistentUpgrades.AttackDamage,
		},
		CampLevel = MetaProgressionDefaults.CampLevel,
		OwnedArtifacts = ownedArtifacts,
		EquippedArtifactId = MetaProgressionDefaults.EquippedArtifactId,
	}
end

return MetaProgressionDefaults
