local ReplicatedStorage = game:GetService("ReplicatedStorage")

local REMOTE_FOLDER_NAME = "GoblinRemotes"

local RemoteNames = {
	PlayerStatsChanged = "PlayerStatsChanged",
	MetaProgressionChanged = "MetaProgressionChanged",
	LevelUpChoices = "LevelUpChoices",
	SelectUpgrade = "SelectUpgrade",
}

local RemoteFunctionNames = {
	GetMetaProgressionSnapshot = "GetMetaProgressionSnapshot",
}

local Remotes = {}

local function getFolder()
	local folder = ReplicatedStorage:FindFirstChild(REMOTE_FOLDER_NAME)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = REMOTE_FOLDER_NAME
		folder.Parent = ReplicatedStorage
	end

	return folder
end

function Remotes.ensure()
	local folder = getFolder()

	for _, remoteName in pairs(RemoteNames) do
		if not folder:FindFirstChild(remoteName) then
			local remote = Instance.new("RemoteEvent")
			remote.Name = remoteName
			remote.Parent = folder
		end
	end

	for _, remoteName in pairs(RemoteFunctionNames) do
		if not folder:FindFirstChild(remoteName) then
			local remote = Instance.new("RemoteFunction")
			remote.Name = remoteName
			remote.Parent = folder
		end
	end

	return folder
end

function Remotes.get(remoteName)
	local folder = Remotes.ensure()
	return folder:WaitForChild(remoteName)
end

Remotes.Names = RemoteNames
Remotes.FunctionNames = RemoteFunctionNames

return Remotes
