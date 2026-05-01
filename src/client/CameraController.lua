local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local PlayerDefaults = require(Shared:WaitForChild("PlayerDefaults"))

local CameraController = {}

local localPlayer = Players.LocalPlayer

local function getRoot()
	local character = localPlayer.Character
	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

function CameraController.start()
	local camera = Workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable

	RunService.RenderStepped:Connect(function()
		local root = getRoot()
		if not root then
			return
		end

		local focusPosition = root.Position
		local cameraPosition = focusPosition + Vector3.new(0, PlayerDefaults.CameraHeight, 0)
		camera.CFrame = CFrame.lookAt(cameraPosition, focusPosition, Vector3.new(0, 0, -1))
	end)
end

return CameraController
