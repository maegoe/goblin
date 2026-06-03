local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))

local Client = script.Parent
local BackgroundMusicController = require(Client:WaitForChild("BackgroundMusicController"))
local CampController = require(Client:WaitForChild("CampController"))
local CameraController = require(Client:WaitForChild("CameraController"))
local FeedbackAudioController = require(Client:WaitForChild("FeedbackAudioController"))
local GoblinAppearanceController = require(Client:WaitForChild("GoblinAppearanceController"))
local HudController = require(Client:WaitForChild("HudController"))
local JumpController = require(Client:WaitForChild("JumpController"))
local LevelUpController = require(Client:WaitForChild("LevelUpController"))
local MetaProgressionController = require(Client:WaitForChild("MetaProgressionController"))
local RunResultController = require(Client:WaitForChild("RunResultController"))

CameraController.start()
JumpController.start()
BackgroundMusicController.start()
FeedbackAudioController.start()
HudController.start()
LevelUpController.start()
MetaProgressionController.start()
GoblinAppearanceController.start()
RunResultController.start()
CampController.start()

print(string.format("[goblin] Client booted for %s", GameConfig.gameName))
