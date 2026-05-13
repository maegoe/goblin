local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))

local MetaProgressionController = {}

local latestSnapshot = nil
local latestStorageMode = nil

local function applyPayload(payload)
	if type(payload) ~= "table" then
		return
	end

	latestSnapshot = payload.snapshot
	latestStorageMode = payload.storageMode
end

function MetaProgressionController.getSnapshot()
	return latestSnapshot
end

function MetaProgressionController.getStorageMode()
	return latestStorageMode
end

function MetaProgressionController.start()
	local snapshotRemote = Remotes.get(Remotes.FunctionNames.GetMetaProgressionSnapshot)
	local ok, payload = pcall(function()
		return snapshotRemote:InvokeServer()
	end)
	if ok then
		applyPayload(payload)
	end

	Remotes.get(Remotes.Names.MetaProgressionChanged).OnClientEvent:Connect(applyPayload)
end

return MetaProgressionController
