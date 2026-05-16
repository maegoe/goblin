local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GoblinAppearanceStages = require(Shared:WaitForChild("GoblinAppearanceStages"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local GoblinAppearanceController = {}

local localPlayer = Players.LocalPlayer
local latestAppearanceStage = GoblinAppearanceStages.getStageForSnapshot(nil)

local function applyBodyColor(character, color)
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" then
			descendant.Color = color
		end
	end
end

local function getHead(character)
	return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
end

local function ensureBadge(character)
	local head = getHead(character)
	if not head then
		return nil, nil
	end

	local badgeGui = head:FindFirstChild("GoblinGrowthBadge")
	if not badgeGui then
		badgeGui = Instance.new("BillboardGui")
		badgeGui.Name = "GoblinGrowthBadge"
		badgeGui.AlwaysOnTop = true
		badgeGui.LightInfluence = 0
		badgeGui.MaxDistance = 120
		badgeGui.Size = UDim2.fromOffset(72, 92)
		badgeGui.StudsOffset = Vector3.new(0, 3.4, 0)
		badgeGui.Parent = head

		local image = Instance.new("ImageLabel")
		image.Name = "Badge"
		image.BackgroundTransparency = 1
		image.Position = UDim2.fromOffset(12, 0)
		image.Size = UDim2.fromOffset(48, 48)
		image.Parent = badgeGui

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBold
		label.Position = UDim2.fromOffset(0, 50)
		label.Size = UDim2.fromOffset(72, 34)
		label.TextColor3 = Color3.fromRGB(247, 244, 226)
		label.TextScaled = true
		label.TextWrapped = true
		label.Parent = badgeGui
	end

	return badgeGui:FindFirstChild("Badge"), badgeGui:FindFirstChild("Label")
end

local function applyAppearance()
	local character = localPlayer.Character
	if not character or type(latestAppearanceStage) ~= "table" then
		return
	end

	local color = latestAppearanceStage.Color
	if typeof(color) ~= "Color3" then
		color = Color3.fromRGB(86, 154, 84)
	end
	applyBodyColor(character, color)

	local badge, label = ensureBadge(character)
	if badge and type(latestAppearanceStage.BadgeAssetId) == "string" then
		badge.Image = latestAppearanceStage.BadgeAssetId
	end
	if label then
		label.Text = string.format("Stage %d", latestAppearanceStage.Stage or 0)
	end
end

local function applyPayload(payload)
	if type(payload) == "table" and type(payload.appearanceStage) == "table" then
		latestAppearanceStage = payload.appearanceStage
		applyAppearance()
	end
end

function GoblinAppearanceController.start()
	localPlayer.CharacterAdded:Connect(function()
		task.defer(applyAppearance)
	end)

	local ok, payload = pcall(function()
		return Remotes.get(Remotes.FunctionNames.GetMetaProgressionSnapshot):InvokeServer()
	end)
	if ok then
		applyPayload(payload)
	end

	Remotes.get(Remotes.Names.MetaProgressionChanged).OnClientEvent:Connect(applyPayload)
	applyAppearance()
end

return GoblinAppearanceController
