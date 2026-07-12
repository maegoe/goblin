local Players = game:GetService("Players")

local JumpController = {}

local localPlayer = Players.LocalPlayer

local function disableHumanoidJump(humanoid)
	humanoid.AutoJumpEnabled = false
	humanoid.UseJumpPower = true
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
	humanoid.Jump = false
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
end

local function onCharacterAdded(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		disableHumanoidJump(humanoid)
	else
		character.ChildAdded:Connect(function(child)
			if child:IsA("Humanoid") then
				disableHumanoidJump(child)
			end
		end)
	end
end

local function hideJumpButton(instance)
	if instance.Name ~= "JumpButton" or not instance:IsA("GuiButton") then
		return
	end

	instance.Visible = false
	instance.Active = false
	instance.Selectable = false
end

local function hideExistingJumpButtons(playerGui)
	for _, descendant in ipairs(playerGui:GetDescendants()) do
		hideJumpButton(descendant)
	end
end

function JumpController.start()
	localPlayer.AutoJumpEnabled = false

	local playerGui = localPlayer:WaitForChild("PlayerGui")
	hideExistingJumpButtons(playerGui)
	playerGui.DescendantAdded:Connect(hideJumpButton)

	localPlayer.CharacterAdded:Connect(onCharacterAdded)
	if localPlayer.Character then
		onCharacterAdded(localPlayer.Character)
	end
end

return JumpController
