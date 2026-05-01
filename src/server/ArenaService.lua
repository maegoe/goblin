local Workspace = game:GetService("Workspace")

local ArenaService = {}

function ArenaService.start()
	if not Workspace:FindFirstChild("ArenaFloor") then
		local floor = Instance.new("Part")
		floor.Name = "ArenaFloor"
		floor.Anchored = true
		floor.Size = Vector3.new(320, 1, 320)
		floor.Position = Vector3.new(0, -0.5, 0)
		floor.Color = Color3.fromRGB(52, 70, 54)
		floor.Material = Enum.Material.Grass
		floor.Parent = Workspace
	end

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
