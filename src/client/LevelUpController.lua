local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))

local LevelUpController = {}

local localPlayer = Players.LocalPlayer
local overlay
local buttons = {}
local buttonConnections = {}

local function toColor3(color)
	if typeof(color) == "table" then
		return Color3.fromRGB(color[1] or 255, color[2] or 255, color[3] or 255)
	end

	return Color3.fromRGB(255, 255, 255)
end

local function createButton(parent, index)
	local button = Instance.new("TextButton")
	button.Name = "Choice" .. index
	button.BackgroundColor3 = Color3.fromRGB(35, 40, 48)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextScaled = true
	button.Size = UDim2.fromOffset(230, 92)
	button.Position = UDim2.fromScale(0.5, 0.36 + ((index - 1) * 0.15))
	button.AnchorPoint = Vector2.new(0.5, 0)
	button.Parent = parent
	return button
end

local function buildUi()
	local playerGui = localPlayer:WaitForChild("PlayerGui")

	overlay = Instance.new("ScreenGui")
	overlay.Name = "LevelUpChoices"
	overlay.ResetOnSpawn = false
	overlay.IgnoreGuiInset = true
	overlay.Enabled = false
	overlay.Parent = playerGui

	local shade = Instance.new("Frame")
	shade.Name = "Shade"
	shade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shade.BackgroundTransparency = 0.35
	shade.BorderSizePixel = 0
	shade.Size = UDim2.fromScale(1, 1)
	shade.Parent = overlay

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBlack
	title.Text = "Level Up"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.Size = UDim2.fromOffset(320, 56)
	title.Position = UDim2.fromScale(0.5, 0.24)
	title.AnchorPoint = Vector2.new(0.5, 0)
	title.Parent = overlay

	for index = 1, 3 do
		buttons[index] = createButton(overlay, index)
	end
end

local function showChoices(choices)
	overlay.Enabled = true

	for index, button in ipairs(buttons) do
		if buttonConnections[index] then
			buttonConnections[index]:Disconnect()
			buttonConnections[index] = nil
		end

		local choice = choices[index]
		if choice then
			button.Visible = true
			button.TextColor3 = toColor3(choice.rarityColor)
			button.Text = string.format("[%s] %s\n%s", choice.rarityLabel, choice.displayName, choice.description)

			buttonConnections[index] = button.Activated:Connect(function()
				overlay.Enabled = false
				for connectionIndex, connection in pairs(buttonConnections) do
					connection:Disconnect()
					buttonConnections[connectionIndex] = nil
				end
				Remotes.get(Remotes.Names.SelectUpgrade):FireServer(choice.id)
			end)
		else
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
			button.Visible = false
		end
	end
end

function LevelUpController.start()
	buildUi()

	Remotes.get(Remotes.Names.LevelUpChoices).OnClientEvent:Connect(showChoices)
end

return LevelUpController
