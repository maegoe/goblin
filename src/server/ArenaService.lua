local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ArenaConfig = require(Shared:WaitForChild("ArenaConfig"))

local ArenaService = {}

local BOUNDARY_FOLDER_NAME = "ArenaBoundaries"

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
	if not Workspace:FindFirstChild("ArenaFloor") then
		local floor = Instance.new("Part")
		floor.Name = "ArenaFloor"
		floor.Anchored = true
		floor.Size = ArenaConfig.FloorSize
		floor.Position = ArenaConfig.FloorPosition
		floor.Color = Color3.fromRGB(52, 70, 54)
		floor.Material = Enum.Material.Grass
		floor.Parent = Workspace
	end

	ensureBoundaries()

	if not Workspace:FindFirstChild("PlayerSpawn") then
		local spawnLocation = Instance.new("SpawnLocation")
		spawnLocation.Name = "PlayerSpawn"
		spawnLocation.Anchored = true
		spawnLocation.Size = Vector3.new(8, 1, 8)
		spawnLocation.Position = Vector3.new(0, 0.05, 0)
		spawnLocation.Neutral = true
		spawnLocation.Transparency = 0.5
		spawnLocation.Parent = Workspace
	end
end

return ArenaService
