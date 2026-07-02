local EnemyStatScaling = {}

EnemyStatScaling.Config = {
	TargetSessionSeconds = 600,
	GraceSeconds = 30,
	CurveExponent = 1.1,
	MaxMultipliers = {
		MaxHealth = 2.2,
		MoveSpeed = 1.28,
		ContactDamage = 1.65,
	},
}

local function isFiniteNumber(value)
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function roundTo(value, step)
	return math.floor((value / step) + 0.5) * step
end

function EnemyStatScaling.getProgress(elapsedSeconds)
	local config = EnemyStatScaling.Config
	if not isFiniteNumber(elapsedSeconds) then
		return 0
	end

	local graceSeconds = math.max(0, config.GraceSeconds or 0)
	local targetSeconds = math.max(graceSeconds + 1, config.TargetSessionSeconds or 600)
	local normalized = math.clamp((elapsedSeconds - graceSeconds) / (targetSeconds - graceSeconds), 0, 1)
	local exponent = config.CurveExponent or 1

	return math.pow(normalized, exponent)
end

function EnemyStatScaling.getMultipliers(elapsedSeconds)
	local progress = EnemyStatScaling.getProgress(elapsedSeconds)
	local maxMultipliers = EnemyStatScaling.Config.MaxMultipliers

	return {
		Progress = progress,
		MaxHealth = 1 + (((maxMultipliers.MaxHealth or 1) - 1) * progress),
		MoveSpeed = 1 + (((maxMultipliers.MoveSpeed or 1) - 1) * progress),
		ContactDamage = 1 + (((maxMultipliers.ContactDamage or 1) - 1) * progress),
	}
end

function EnemyStatScaling.apply(definition, elapsedSeconds)
	local multipliers = EnemyStatScaling.getMultipliers(elapsedSeconds)
	local maxHealth = math.max(1, math.floor((definition.MaxHealth * multipliers.MaxHealth) + 0.5))
	local moveSpeed = roundTo(definition.MoveSpeed * multipliers.MoveSpeed, 0.01)
	local contactDamage = math.max(1, roundTo(definition.ContactDamage * multipliers.ContactDamage, 0.1))

	return {
		MaxHealth = maxHealth,
		MoveSpeed = moveSpeed,
		ContactDamage = contactDamage,
		Progress = multipliers.Progress,
		Multipliers = multipliers,
		ElapsedSeconds = isFiniteNumber(elapsedSeconds) and math.max(0, elapsedSeconds) or 0,
	}
end

return EnemyStatScaling
