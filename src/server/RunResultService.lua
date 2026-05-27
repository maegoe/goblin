local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))
local RunRewardConfig = require(Shared:WaitForChild("RunRewardConfig"))

local MetaProgressionService = require(script.Parent:WaitForChild("MetaProgressionService"))

local RunResultService = {}

local runEndedRemote

local function getRunEndedRemote()
	if not runEndedRemote then
		runEndedRemote = Remotes.get(Remotes.Names.RunEnded)
	end

	return runEndedRemote
end

local function calculateRewards(survivalTime, killCount, levelReached)
	local seconds = math.max(0, math.floor(survivalTime))
	local kills = math.max(0, math.floor(killCount))
	local level = math.max(1, math.floor(levelReached))

	local growthStones = math.floor(seconds / RunRewardConfig.GrowthStoneSecondsDivisor)
		+ math.floor(kills / RunRewardConfig.GrowthStoneKillsDivisor)
		+ ((level - 1) * RunRewardConfig.GrowthStonePerLevelAfterFirst)
	local campMaterials = math.floor(seconds / RunRewardConfig.CampMaterialSecondsDivisor)
		+ math.floor(kills / RunRewardConfig.CampMaterialKillsDivisor)

	return growthStones, campMaterials
end

function RunResultService.endRun(player, state, endReason)
	if not player or not state then
		return nil
	end

	local survivalTime = state.SurvivalTime or 0
	local killCount = state.KillCount or 0
	local levelReached = state.Level or 1
	local growthStonesEarned, campMaterialsEarned = calculateRewards(survivalTime, killCount, levelReached)

	local _, snapshot = MetaProgressionService.update(player, function(progression)
		progression.GrowthStones += growthStonesEarned
		progression.CampMaterials += campMaterialsEarned
	end)

	local result = {
		SurvivalTime = survivalTime,
		KillCount = killCount,
		LevelReached = levelReached,
		GrowthStonesEarned = growthStonesEarned,
		CampMaterialsEarned = campMaterialsEarned,
		EndReason = endReason,
		Progression = snapshot,
	}

	getRunEndedRemote():FireClient(player, result)
	print(string.format(
		"[goblin][RunResult] %s ended run; reason=%s survival=%.1f kills=%d level=%d growthStones=%d campMaterials=%d",
		player.Name,
		tostring(endReason),
		survivalTime,
		killCount,
		levelReached,
		growthStonesEarned,
		campMaterialsEarned
	))

	return result
end

function RunResultService.start()
	getRunEndedRemote()
end

return RunResultService
