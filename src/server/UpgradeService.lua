local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))

local PlayerStateService = require(script.Parent:WaitForChild("PlayerStateService"))

local UpgradeService = {}

function UpgradeService.start()
	Remotes.get(Remotes.Names.SelectUpgrade).OnServerEvent:Connect(function(player, upgradeId)
		if typeof(upgradeId) ~= "string" then
			return
		end

		PlayerStateService.applyUpgrade(player, upgradeId)
	end)
end

return UpgradeService
