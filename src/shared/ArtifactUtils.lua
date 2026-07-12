local ArtifactDefinitions = require(script.Parent:WaitForChild("ArtifactDefinitions"))

local ArtifactUtils = {}

function ArtifactUtils.getDefinition(artifactId)
	if type(artifactId) ~= "string" then
		return nil
	end

	return ArtifactDefinitions[artifactId]
end

function ArtifactUtils.owns(progression, artifactId)
	local ownedArtifacts = progression and progression.OwnedArtifacts
	if type(ownedArtifacts) ~= "table" then
		return false
	end

	for _, ownedArtifactId in ipairs(ownedArtifacts) do
		if ownedArtifactId == artifactId then
			return true
		end
	end

	return false
end

function ArtifactUtils.getOrderedOwnedIds(progression)
	local ownedArtifactIds = {}
	for _, artifactId in ipairs(ArtifactDefinitions.Order) do
		if ArtifactUtils.owns(progression, artifactId) then
			table.insert(ownedArtifactIds, artifactId)
		end
	end

	return ownedArtifactIds
end

function ArtifactUtils.getIconAssetId(definition, assetTable, fallbackAssetId)
	if not definition or type(definition.IconAssetKey) ~= "string" or type(assetTable) ~= "table" then
		return fallbackAssetId
	end

	local assetId = assetTable[definition.IconAssetKey]
	if type(assetId) == "string" then
		return assetId
	end

	return fallbackAssetId
end

function ArtifactUtils.getStateLabel(progression, artifactId)
	if progression and progression.EquippedArtifactId == artifactId then
		return "Equipped"
	end

	if ArtifactUtils.owns(progression, artifactId) then
		return "Owned"
	end

	return "Locked"
end

function ArtifactUtils.formatEffect(definition)
	if not definition then
		return "Effect: None"
	end

	if definition.EffectType == "StatBonus" then
		return string.format("Effect: %+g %s", definition.Value or 0, definition.StatKey or "Stat")
	end

	if definition.EffectType == "WeakExplosion" then
		return string.format(
			"Effect: %d%% explosion damage, %d stud radius",
			math.floor(((definition.ExplosionDamageMultiplier or 0) * 100) + 0.5),
			definition.ExplosionRadius or 0
		)
	end

	return "Effect: " .. (definition.Description or "None")
end

return ArtifactUtils
