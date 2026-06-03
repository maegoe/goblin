local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ArenaConfig = require(Shared:WaitForChild("ArenaConfig"))

local ArenaService = {}

local BOUNDARY_FOLDER_NAME = "ArenaBoundaries"
local FLOOR_TEXTURE_NAME = "ArenaFloorTileTexture"

local function shouldLogFloorTile()
	return ArenaConfig.FloorTileDebugLogging == true and RunService:IsStudio()
end

local function logFloorTile(message)
	if shouldLogFloorTile() then
		print("[goblin][ArenaFloorTile] " .. message)
	end
end

local function warnFloorTile(message)
	if shouldLogFloorTile() then
		warn("[goblin][ArenaFloorTile] " .. message)
	end
end

local function logFloorTilePreload(tileTexture)
	if not shouldLogFloorTile() then
		return
	end

	task.spawn(function()
		local ok, err = pcall(function()
			ContentProvider:PreloadAsync({ tileTexture }, function(contentId, assetFetchStatus)
				logFloorTile(("preload contentId=%s status=%s"):format(
					tostring(contentId),
					tostring(assetFetchStatus)
				))
			end)
		end)

		if not ok then
			warnFloorTile("preload failed: " .. tostring(err))
		end
	end)
end

local function applyFloorVisuals(floor, createdFloor)
	floor.Anchored = true
	floor.Size = ArenaConfig.FloorSize
	floor.Position = ArenaConfig.FloorPosition
	floor.Color = Color3.fromRGB(52, 70, 54)
	floor.Material = Enum.Material.Grass

	local textureAssetId = ArenaConfig.FloorTileTexture
	local tileTexture = floor:FindFirstChild(FLOOR_TEXTURE_NAME)
	if tileTexture and not tileTexture:IsA("Texture") then
		tileTexture:Destroy()
		tileTexture = nil
	end

	if type(textureAssetId) ~= "string" or textureAssetId == "" then
		if tileTexture then
			tileTexture:Destroy()
		end
		warnFloorTile("no FloorTileTexture configured; using base floor material fallback")
		return
	end

	local createdTexture = false
	if not tileTexture then
		tileTexture = Instance.new("Texture")
		tileTexture.Name = FLOOR_TEXTURE_NAME
		tileTexture.Parent = floor
		createdTexture = true
	end

	tileTexture.Texture = textureAssetId
	tileTexture.Face = Enum.NormalId.Top
	tileTexture.StudsPerTileU = ArenaConfig.FloorTileStuds.X
	tileTexture.StudsPerTileV = ArenaConfig.FloorTileStuds.Y

	logFloorTile(("floorCreated=%s textureCreated=%s floorSize=%s floorPosition=%s texture=%s face=%s studsPerTile=(%s,%s) parent=%s"):format(
		tostring(createdFloor),
		tostring(createdTexture),
		tostring(floor.Size),
		tostring(floor.Position),
		tileTexture.Texture,
		tostring(tileTexture.Face),
		tostring(tileTexture.StudsPerTileU),
		tostring(tileTexture.StudsPerTileV),
		tileTexture.Parent and tileTexture.Parent:GetFullName() or "nil"
	))
	logFloorTilePreload(tileTexture)
end

local function upsertBoundary(folder, name, size, position)
	local boundary = folder:FindFirstChild(name)
	if not boundary then
		boundary = Instance.new("Part")
		boundary.Name = name
		boundary.Parent = folder
	end

	boundary.Anchored = true
	boundary.CanCollide = true
	boundary.CanTouch = false
	boundary.CanQuery = false
	boundary.Transparency = 1
	boundary.Size = size
	boundary.Position = position

	return boundary
end

local function ensureBoundaries()
	local folder = Workspace:FindFirstChild(BOUNDARY_FOLDER_NAME)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = BOUNDARY_FOLDER_NAME
		folder.Parent = Workspace
	end

	local halfX, halfZ = ArenaConfig.getHalfExtents()
	local thickness = ArenaConfig.BoundaryThickness
	local height = ArenaConfig.BoundaryHeight
	local centerY = height / 2

	upsertBoundary(
		folder,
		"North",
		Vector3.new(ArenaConfig.FloorSize.X + (thickness * 2), height, thickness),
		Vector3.new(0, centerY, halfZ + (thickness / 2))
	)
	upsertBoundary(
		folder,
		"South",
		Vector3.new(ArenaConfig.FloorSize.X + (thickness * 2), height, thickness),
		Vector3.new(0, centerY, -halfZ - (thickness / 2))
	)
	upsertBoundary(
		folder,
		"East",
		Vector3.new(thickness, height, ArenaConfig.FloorSize.Z),
		Vector3.new(halfX + (thickness / 2), centerY, 0)
	)
	upsertBoundary(
		folder,
		"West",
		Vector3.new(thickness, height, ArenaConfig.FloorSize.Z),
		Vector3.new(-halfX - (thickness / 2), centerY, 0)
	)
end

function ArenaService.start()
	local floor = Workspace:FindFirstChild("ArenaFloor")
	local createdFloor = false
	if not floor then
		floor = Instance.new("Part")
		floor.Name = "ArenaFloor"
		floor.Parent = Workspace
		createdFloor = true
	end
	applyFloorVisuals(floor, createdFloor)

	ensureBoundaries()

	if not Workspace:FindFirstChild("PlayerSpawn") then
		local spawnLocation = Instance.new("SpawnLocation")
		spawnLocation.Name = "PlayerSpawn"
		spawnLocation.Anchored = true
		spawnLocation.Size = Vector3.new(8, ArenaConfig.FloorSize.Y, 8)
		spawnLocation.Position = Vector3.new(0, ArenaConfig.FloorPosition.Y, 0)
		spawnLocation.Neutral = true
		spawnLocation.Transparency = 1
		spawnLocation.Parent = Workspace
	end
end

return ArenaService
