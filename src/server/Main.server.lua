local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local Server = script.Parent
local ArenaService = require(Server:WaitForChild("ArenaService"))
local MetaProgressionService = require(Server:WaitForChild("MetaProgressionService"))
local RunResultService = require(Server:WaitForChild("RunResultService"))
local PlayerStateService = require(Server:WaitForChild("PlayerStateService"))
local EnemyService = require(Server:WaitForChild("EnemyService"))
local WaveService = require(Server:WaitForChild("WaveService"))
local CombatService = require(Server:WaitForChild("CombatService"))
local UpgradeService = require(Server:WaitForChild("UpgradeService"))

Remotes.ensure()
ArenaService.start()
MetaProgressionService.start()
RunResultService.start()
PlayerStateService.start()
EnemyService.start()
UpgradeService.start()
CombatService.start()
WaveService.start()

print(string.format("[goblin] Server booted for %s", GameConfig.gameName))
