local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ArtifactUtils = require(Shared:WaitForChild("ArtifactUtils"))

local ArtifactEffectService = {}

ArtifactEffectService.ExplosionRadiusCap = 18
ArtifactEffectService.ExplosionDamageMultiplierCap = 0.8
ArtifactEffectService.ExplosionStackRadiusBonus = 4
ArtifactEffectService.ExplosionStackDamageMultiplierBonus = 0.15

local function isFiniteNumber(value)
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function copyArray(values)
	local result = {}
	if type(values) ~= "table" then
		return result
	end

	for _, value in ipairs(values) do
		table.insert(result, value)
	end

	return result
end

local function buildExplosionPayload(baseRadius, baseDamageMultiplier, sources)
	local sourceCount = #sources
	local amplified = sourceCount >= 2
	local radius = baseRadius
	local damageMultiplier = baseDamageMultiplier

	if amplified then
		radius += ArtifactEffectService.ExplosionStackRadiusBonus
		damageMultiplier += ArtifactEffectService.ExplosionStackDamageMultiplierBonus
	end

	return {
		Radius = math.min(radius, ArtifactEffectService.ExplosionRadiusCap),
		DamageMultiplier = math.min(damageMultiplier, ArtifactEffectService.ExplosionDamageMultiplierCap),
		BaseRadius = baseRadius,
		BaseDamageMultiplier = baseDamageMultiplier,
		SourceCount = sourceCount,
		Sources = sources,
		Amplified = amplified,
		RadiusCap = ArtifactEffectService.ExplosionRadiusCap,
		DamageMultiplierCap = ArtifactEffectService.ExplosionDamageMultiplierCap,
		StackRadiusBonus = ArtifactEffectService.ExplosionStackRadiusBonus,
		StackDamageMultiplierBonus = ArtifactEffectService.ExplosionStackDamageMultiplierBonus,
	}
end

function ArtifactEffectService.combineExplosiveBolt(currentExplosion, nextExplosion)
	if type(nextExplosion) ~= "table" then
		return currentExplosion
	end

	local nextRadius = nextExplosion.Radius
	local nextMultiplier = nextExplosion.DamageMultiplier
	if not isFiniteNumber(nextRadius) or not isFiniteNumber(nextMultiplier) then
		return currentExplosion
	end
	local nextSource = nextExplosion.Source or "Unknown"

	if not currentExplosion then
		return buildExplosionPayload(nextRadius, nextMultiplier, { nextSource })
	end

	local sources = copyArray(currentExplosion.Sources)
	table.insert(sources, nextSource)
	local baseRadius = math.max(currentExplosion.BaseRadius or currentExplosion.Radius or 0, nextRadius)
	local baseDamageMultiplier = (currentExplosion.BaseDamageMultiplier or currentExplosion.DamageMultiplier or 0) + nextMultiplier

	return buildExplosionPayload(baseRadius, baseDamageMultiplier, sources)
end

function ArtifactEffectService.applyEquippedArtifact(state, progression)
	local artifactId = progression and progression.EquippedArtifactId
	if type(artifactId) ~= "string" then
		return
	end

	state.EquippedArtifactId = artifactId
	local definition = ArtifactUtils.getDefinition(artifactId)
	if not definition then
		return
	end

	if definition.EffectType == "StatBonus" and definition.StatKey == "MoveSpeed" and isFiniteNumber(definition.Value) then
		state.MoveSpeed += definition.Value
	elseif definition.EffectType == "WeakExplosion" then
		state.ExplosiveBolt = ArtifactEffectService.combineExplosiveBolt(state.ExplosiveBolt, {
			Radius = definition.ExplosionRadius,
			DamageMultiplier = definition.ExplosionDamageMultiplier,
			Source = definition.Id or artifactId or "Artifact",
		})
	end
end

return ArtifactEffectService
