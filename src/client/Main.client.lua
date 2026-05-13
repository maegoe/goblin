local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))

local Client = script.Parent
local CameraController = require(Client:WaitForChild("CameraController"))
local HudController = require(Client:WaitForChild("HudController"))
local LevelUpController = require(Client:WaitForChild("LevelUpController"))
local MetaProgressionController = require(Client:WaitForChild("MetaProgressionController"))
local RunResultController = require(Client:WaitForChild("RunResultController"))

CameraController.start()
HudController.start()
LevelUpController.start()
MetaProgressionController.start()
RunResultController.start()

print(string.format("[goblin] Client booted for %s", GameConfig.gameName))
