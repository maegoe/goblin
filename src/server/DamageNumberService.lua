local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local DamageNumberService = {}

local DAMAGE_NUMBER_LIFETIME = 0.65
local DAMAGE_NUMBER_RISE = 2.5
local DAMAGE_NUMBER_FOLDER_NAME = "DamageNumbers"

local function getDamageNumberFolder()
	local folder = Workspace:FindFirstChild(DAMAGE_NUMBER_FOLDER_NAME)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = DAMAGE_NUMBER_FOLDER_NAME
		folder.Parent = Workspace
	end

	return folder
end

local function formatDamageAmount(amount)
	if amount % 1 == 0 then
		return tostring(amount)
	end

	return string.format("%.1f", amount):gsub("0+$", ""):gsub("%.$", "")
end

function DamageNumberService.show(position, amount)
	local marker = Instance.new("Part")
	marker.Name = "DamageNumber"
	marker.Anchored = true
	marker.CanCollide = false
	marker.CanQuery = false
	marker.CanTouch = false
	marker.Transparency = 1
	marker.Size = Vector3.new(0.2, 0.2, 0.2)
	marker.Position = position + Vector3.new(0, 3.25, 0)
	marker.Parent = getDamageNumberFolder()

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "DamageNumberBillboard"
	billboard.Adornee = marker
	billboard.AlwaysOnTop = true
	billboard.LightInfluence = 0
	billboard.MaxDistance = 180
	billboard.Size = UDim2.fromOffset(80, 34)
	billboard.Parent = marker

	local label = Instance.new("TextLabel")
	label.Name = "Amount"
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = formatDamageAmount(amount)
	label.TextColor3 = Color3.fromRGB(255, 238, 126)
	label.TextScaled = true
	label.TextStrokeColor3 = Color3.fromRGB(44, 28, 18)
	label.TextStrokeTransparency = 0.15
	label.Size = UDim2.fromScale(1, 1)
	label.Parent = billboard

	local tweenInfo = TweenInfo.new(DAMAGE_NUMBER_LIFETIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(marker, tweenInfo, {
		Position = marker.Position + Vector3.new(0, DAMAGE_NUMBER_RISE, 0),
	}):Play()
	TweenService:Create(label, tweenInfo, {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}):Play()

	Debris:AddItem(marker, DAMAGE_NUMBER_LIFETIME + 0.1)
end

return DamageNumberService
