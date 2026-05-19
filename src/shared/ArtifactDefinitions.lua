local ArtifactDefinitions = {
	SwiftCharm = {
		Id = "SwiftCharm",
		DisplayName = "Swift Charm",
		Description = "+1 movement speed",
		SlotType = "Artifact",
		EffectType = "StatBonus",
		StatKey = "MoveSpeed",
		Value = 1,
		IconAssetKey = "icon_artifact_swift_charm_default_256x256",
	},
	BlastCore = {
		Id = "BlastCore",
		DisplayName = "Blast Core",
		Description = "Basic bolts explode for 20% damage",
		SlotType = "Artifact",
		EffectType = "WeakExplosion",
		ExplosionDamageMultiplier = 0.2,
		ExplosionRadius = 10,
		IconAssetKey = "icon_artifact_blast_core_default_256x256",
	},
}

ArtifactDefinitions.Order = {
	"SwiftCharm",
	"BlastCore",
}

ArtifactDefinitions.DefaultOwned = {
	"SwiftCharm",
	"BlastCore",
}

return ArtifactDefinitions
