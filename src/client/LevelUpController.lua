local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))

local LevelUpController = {}

local localPlayer = Players.LocalPlayer
local overlay
local buttons = {}
local buttonConnections = {}

local RARE_CARD_DEFAULT_IMAGE = "rbxassetid://90606942276385"
local RARE_CARD_SELECTED_IMAGE = "rbxassetid://99822713894854"

local function toColor3(color)
	if typeof(color) == "table" then
		return Color3.fromRGB(color[1] or 255, color[2] or 255, color[3] or 255)
	end

	return Color3.fromRGB(255, 255, 255)
end

local function getRarityAssets(rarity)
	if rarity == "rare" then
		return RARE_CARD_DEFAULT_IMAGE, RARE_CARD_SELECTED_IMAGE
	end

	return "", ""
end

local function createButton(parent, index)
	local button = Instance.new("ImageButton")
	button.Name = "Choice" .. index
	button.BackgroundColor3 = Color3.fromRGB(35, 40, 48)
	button.BorderSizePixel = 0
	button.Size = UDim2.fromOffset(230, 92)
	button.Position = UDim2.fromScale(0.5, 0.36 + ((index - 1) * 0.15))
	button.AnchorPoint = Vector2.new(0.5, 0)
	button.ScaleType = Enum.ScaleType.Slice
	button.SliceCenter = Rect.new(24, 24, 488, 232)
	button.Parent = parent

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Size = UDim2.fromScale(0.88, 0.78)
	label.Position = UDim2.fromScale(0.5, 0.5)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Parent = button

	return {
		button = button,
		label = label,
	}
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

	for index, choiceButton in ipairs(buttons) do
		local button = choiceButton.button
		local label = choiceButton.label

		if buttonConnections[index] then
			buttonConnections[index]:Disconnect()
			buttonConnections[index] = nil
		end

		local choice = choices[index]
		if choice then
			local defaultImage, selectedImage = getRarityAssets(choice.rarity)

			button.Visible = true
			button.Image = defaultImage
			button.PressedImage = selectedImage
			button.HoverImage = selectedImage
			button.BackgroundTransparency = defaultImage == "" and 0 or 1

			label.TextColor3 = toColor3(choice.rarityColor)
			label.Text = string.format("[%s] %s\n%s", choice.rarityLabel, choice.displayName, choice.description)

			buttonConnections[index] = button.Activated:Connect(function()
				overlay.Enabled = false
				for connectionIndex, connection in pairs(buttonConnections) do
					connection:Disconnect()
					buttonConnections[connectionIndex] = nil
				end
				Remotes.get(Remotes.Names.SelectUpgrade):FireServer(choice.id)
			end)
		else
			button.Image = ""
			button.PressedImage = ""
			button.HoverImage = ""
			button.BackgroundTransparency = 0
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
			label.Text = ""
			button.Visible = false
		end
	end
end

function LevelUpController.start()
	buildUi()

	Remotes.get(Remotes.Names.LevelUpChoices).OnClientEvent:Connect(showChoices)
end

return LevelUpController
