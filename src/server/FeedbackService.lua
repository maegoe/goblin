local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local FeedbackEvents = require(Shared:WaitForChild("FeedbackEvents"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local FeedbackService = {}

local feedbackRemote
local validEvents = {}

for _, eventName in pairs(FeedbackEvents) do
	validEvents[eventName] = true
end

local function getFeedbackRemote()
	if not feedbackRemote then
		feedbackRemote = Remotes.get(Remotes.Names.FeedbackAudio)
	end

	return feedbackRemote
end

function FeedbackService.play(player, eventName)
	if not player or not validEvents[eventName] then
		return
	end

	getFeedbackRemote():FireClient(player, eventName)
end

return FeedbackService
