local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ArenaConfig = require(Shared:WaitForChild("ArenaConfig"))
local Assets = require(Shared:WaitForChild("Assets"))
local AudioAssets = require(Shared:WaitForChild("AudioAssets"))
local EnemyDefinitions = require(Shared:WaitForChild("EnemyDefinitions"))
local WeaponDefinitions = require(Shared:WaitForChild("WeaponDefinitions"))

local LoadingController = {}

local ASSET_ID_PREFIX = "rbxassetid://"
local MIN_LOADING_SECONDS = 5
local EXTRA_ASSET_IDS = {
	-- Player sprite sheets are local runtime constants in GoblinAppearanceController.
	"rbxassetid://118274519536442",
	"rbxassetid://139275661229908",
	"rbxassetid://90889400666043",
}

local localPlayer = Players.LocalPlayer
local gui
local progressFill
local percentText
local statusText

local function isAssetId(value)
	return type(value) == "string" and string.sub(value, 1, #ASSET_ID_PREFIX) == ASSET_ID_PREFIX
end

local function collectAssetIds(value, seen, output)
	if isAssetId(value) then
		if not seen[value] then
			seen[value] = true
			table.insert(output, value)
		end
		return
	end

	if type(value) ~= "table" then
		return
	end

	for _, child in pairs(value) do
		collectAssetIds(child, seen, output)
	end
end

local function getPreloadAssetIds()
	local seen = {}
	local assetIds = {}

	collectAssetIds(Assets, seen, assetIds)
	collectAssetIds(AudioAssets, seen, assetIds)
	collectAssetIds(ArenaConfig, seen, assetIds)
	collectAssetIds(EnemyDefinitions, seen, assetIds)
	collectAssetIds(WeaponDefinitions, seen, assetIds)
	collectAssetIds(EXTRA_ASSET_IDS, seen, assetIds)

	table.sort(assetIds)
	return assetIds
end

local function createLabel(parent, name, text, position, size, textSize, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = color
	label.TextScaled = true
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Position = position
	label.Size = size
	label.Parent = parent

	local textLimit = Instance.new("UITextSizeConstraint")
	textLimit.MinTextSize = 10
	textLimit.MaxTextSize = textSize
	textLimit.Parent = label

	return label
end

local function buildLoadingGui()
	local playerGui = localPlayer:WaitForChild("PlayerGui")

	gui = Instance.new("ScreenGui")
	gui.Name = "GoblinLoading"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 1000
	gui.Parent = playerGui

	local root = Instance.new("Frame")
	root.Name = "Root"
	root.BackgroundColor3 = Color3.fromRGB(8, 10, 11)
	root.BorderSizePixel = 0
	root.Size = UDim2.fromScale(1, 1)
	root.Parent = gui

	createLabel(root, "Title", "Goblin", UDim2.fromScale(0.28, 0.31), UDim2.fromScale(0.44, 0.11), 46, Color3.fromRGB(247, 244, 226))
	createLabel(root, "Subtitle", "Loading assets", UDim2.fromScale(0.28, 0.43), UDim2.fromScale(0.44, 0.05), 18, Color3.fromRGB(190, 181, 150))

	local barTrack = Instance.new("Frame")
	barTrack.Name = "ProgressTrack"
	barTrack.AnchorPoint = Vector2.new(0.5, 0)
	barTrack.BackgroundColor3 = Color3.fromRGB(22, 25, 27)
	barTrack.BorderSizePixel = 0
	barTrack.Position = UDim2.fromScale(0.5, 0.53)
	barTrack.Size = UDim2.fromScale(0.42, 0.025)
	barTrack.Parent = root

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(0, 6)
	trackCorner.Parent = barTrack

	progressFill = Instance.new("Frame")
	progressFill.Name = "ProgressFill"
	progressFill.BackgroundColor3 = Color3.fromRGB(123, 188, 99)
	progressFill.BorderSizePixel = 0
	progressFill.Size = UDim2.fromScale(0, 1)
	progressFill.Parent = barTrack

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 6)
	fillCorner.Parent = progressFill

	percentText = createLabel(root, "Percent", "0%", UDim2.fromScale(0.39, 0.575), UDim2.fromScale(0.22, 0.04), 16, Color3.fromRGB(247, 244, 226))
	statusText = createLabel(root, "Status", "Preparing", UDim2.fromScale(0.28, 0.62), UDim2.fromScale(0.44, 0.05), 14, Color3.fromRGB(190, 181, 150))
end

local function setProgress(loaded, total, message)
	local ratio = if total > 0 then math.clamp(loaded / total, 0, 1) else 1
	if progressFill then
		progressFill.Size = UDim2.fromScale(ratio, 1)
	end
	if percentText then
		percentText.Text = string.format("%d%%", math.floor((ratio * 100) + 0.5))
	end
	if statusText then
		statusText.Text = message or string.format("%d / %d", loaded, total)
	end
end

function LoadingController.start()
	local startedAt = time()
	buildLoadingGui()

	local assetIds = getPreloadAssetIds()
	local total = #assetIds
	local loaded = 0
	local failedAssetIds = {}

	setProgress(0, total, string.format("Preparing %d assets", total))
	task.wait()

	local ok, err = pcall(function()
		ContentProvider:PreloadAsync(assetIds, function(assetId, status)
			loaded += 1
			if status ~= Enum.AssetFetchStatus.Success then
				table.insert(failedAssetIds, tostring(assetId))
			end
			setProgress(loaded, total, string.format("Loading %d / %d", math.min(loaded, total), total))
		end)
	end)

	if not ok then
		warn(string.format("[goblin] Asset preload error: %s", tostring(err)))
	end

	local failed = #failedAssetIds
	if failed > 0 then
		local sampleCount = math.min(failed, 5)
		local sample = table.concat(failedAssetIds, ", ", 1, sampleCount)
		local suffix = if failed > sampleCount then string.format(" (+%d more)", failed - sampleCount) else ""
		warn(string.format("[goblin] Asset preload finished with %d warning(s): %s%s", failed, sample, suffix))
	end

	setProgress(total, total, if failed > 0 then string.format("Loaded with %d warnings", failed) else "Complete")

	local remainingSeconds = MIN_LOADING_SECONDS - (time() - startedAt)
	if remainingSeconds > 0 then
		task.wait(remainingSeconds)
	end
	print(string.format("[goblin] Loading screen completed in %.2fs (%d assets, %d warning(s))", time() - startedAt, total, failed))

	if gui then
		gui:Destroy()
		gui = nil
	end

	return ok, {
		total = total,
		failed = failed,
		error = if ok then nil else tostring(err),
	}
end

return LoadingController
