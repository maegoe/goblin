local ArenaConfig = {
	FloorSize = Vector3.new(320, 1, 320),
	FloorPosition = Vector3.new(0, -0.5, 0),
	BoundaryHeight = 40,
	BoundaryThickness = 2,
	SpawnMargin = 10,
	EnemyMovementMargin = 3,
	FloorTileTexture = "rbxassetid://89096359055479",
	FloorTileStuds = Vector2.new(32, 32),
	FloorTileDebugLogging = true,
}

function ArenaConfig.getHalfExtents()
	return ArenaConfig.FloorSize.X / 2, ArenaConfig.FloorSize.Z / 2
end

function ArenaConfig.clampToArena(position, margin)
	local inset = margin or 0
	local halfX, halfZ = ArenaConfig.getHalfExtents()
	local minX = -halfX + inset
	local maxX = halfX - inset
	local minZ = -halfZ + inset
	local maxZ = halfZ - inset

	return Vector3.new(
		math.clamp(position.X, minX, maxX),
		position.Y,
		math.clamp(position.Z, minZ, maxZ)
	)
end

return ArenaConfig
