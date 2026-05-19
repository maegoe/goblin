local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ArtifactDefinitions = require(Shared:WaitForChild("ArtifactDefinitions"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local MetaProgressionService = require(script.Parent:WaitForChild("MetaProgressionService"))

local ArtifactService = {}

local equipRemote
local unequipRemote

local function ownsArtifact(snapshot, artifactId)
	local ownedArtifacts = snapshot and snapshot.OwnedArtifacts
	if type(ownedArtifacts) ~= "table" then
		return false
	end

	for _, ownedArtifactId in ipairs(ownedArtifacts) do
		if ownedArtifactId == artifactId then
			return true
		end
	end

	return false
end

function ArtifactService.equip(player, artifactId)
	local definition = ArtifactDefinitions[artifactId]
	if not definition then
		return false, "UnknownArtifact"
	end

	local snapshot = MetaProgressionService.getSnapshot(player)
	if not snapshot then
		return false, "NoProgression"
	end
	if not ownsArtifact(snapshot, artifactId) then
		return false, "NotOwned"
	end

	local saved = MetaProgressionService.update(player, function(progression)
		if not ownsArtifact(progression, artifactId) then
			return false
		end

		progression.EquippedArtifactId = artifactId
	end)

	if not saved then
		return false, "SaveFallbackOrRejected"
	end

	print(string.format("[goblin][Artifact] %s equipped %s", player.Name, artifactId))
	return true, nil
end

function ArtifactService.unequip(player)
	local snapshot = MetaProgressionService.getSnapshot(player)
	if not snapshot then
		return false, "NoProgression"
	end
	if snapshot.EquippedArtifactId == nil then
		return true, nil
	end

	local saved = MetaProgressionService.update(player, function(progression)
		progression.EquippedArtifactId = nil
	end)

	if not saved then
		return false, "SaveFallbackOrRejected"
	end

	print(string.format("[goblin][Artifact] %s unequipped artifact", player.Name))
	return true, nil
end

function ArtifactService.start()
	equipRemote = Remotes.get(Remotes.Names.EquipArtifact)
	unequipRemote = Remotes.get(Remotes.Names.UnequipArtifact)

	equipRemote.OnServerEvent:Connect(function(player, artifactId)
		if typeof(artifactId) ~= "string" then
			return
		end

		local ok, reason = ArtifactService.equip(player, artifactId)
		if not ok then
			print(string.format(
				"[goblin][Artifact] rejected equip %s for %s: %s",
				tostring(artifactId),
				player.Name,
				tostring(reason)
			))
		end
	end)

	unequipRemote.OnServerEvent:Connect(function(player)
		local ok, reason = ArtifactService.unequip(player)
		if not ok then
			print(string.format("[goblin][Artifact] rejected unequip for %s: %s", player.Name, tostring(reason)))
		end
	end)
end

return ArtifactService
