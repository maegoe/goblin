local PlayerStateService = require(script.Parent:WaitForChild("PlayerStateService"))

local ExperienceService = {}

function ExperienceService.awardKill(player, killInfo)
	if not player or not killInfo then
		return
	end

	PlayerStateService.recordKill(player)
	PlayerStateService.addExperience(player, killInfo.experienceReward)
end

return ExperienceService
