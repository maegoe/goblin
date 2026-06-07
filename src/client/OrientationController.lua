local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local OrientationController = {}

local localPlayer = Players.LocalPlayer
local TARGET_ORIENTATION = Enum.ScreenOrientation.LandscapeSensor

local function applyPlayerGuiOrientation(playerGui)
	if playerGui.ScreenOrientation == TARGET_ORIENTATION then
		return
	end

	playerGui.ScreenOrientation = TARGET_ORIENTATION
end

function OrientationController.start()
	StarterGui.ScreenOrientation = TARGET_ORIENTATION

	local playerGui = localPlayer:WaitForChild("PlayerGui")
	applyPlayerGuiOrientation(playerGui)

	playerGui:GetPropertyChangedSignal("ScreenOrientation"):Connect(function()
		applyPlayerGuiOrientation(playerGui)
	end)
end

return OrientationController
