local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local AudioAssets = require(Shared:WaitForChild("AudioAssets"))
local FeedbackEvents = require(Shared:WaitForChild("FeedbackEvents"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local FeedbackAudioController = {}

local audio = AudioAssets.v1_0
local sounds = {
	[FeedbackEvents.PlayerHit] = audio.combat.player_hit_01,
	[FeedbackEvents.EnemyHit] = audio.combat.enemy_hit_01,
	[FeedbackEvents.EnemyDeath] = audio.combat.enemy_death_01,
	[FeedbackEvents.LevelUp] = audio.ui.level_up_01,
	[FeedbackEvents.UpgradeSelect] = audio.ui.upgrade_select_01,
	[FeedbackEvents.RewardGain] = audio.ui.reward_gain_01,
	[FeedbackEvents.CampPurchase] = audio.camp.camp_purchase_01,
}

local cooldowns = {
	[FeedbackEvents.PlayerHit] = 0.15,
	[FeedbackEvents.EnemyHit] = 0.08,
	[FeedbackEvents.EnemyDeath] = 0.08,
	[FeedbackEvents.LevelUp] = 0.2,
	[FeedbackEvents.UpgradeSelect] = 0.15,
	[FeedbackEvents.RewardGain] = 0.25,
	[FeedbackEvents.CampPurchase] = 0.2,
}

local volumes = {
	[FeedbackEvents.PlayerHit] = 0.45,
	[FeedbackEvents.EnemyHit] = 0.35,
	[FeedbackEvents.EnemyDeath] = 0.42,
	[FeedbackEvents.LevelUp] = 0.5,
	[FeedbackEvents.UpgradeSelect] = 0.42,
	[FeedbackEvents.RewardGain] = 0.45,
	[FeedbackEvents.CampPurchase] = 0.45,
}

local lastPlayedAt = {}
local started = false

function FeedbackAudioController.play(eventName)
	local soundId = sounds[eventName]
	if type(soundId) ~= "string" or soundId == "" then
		return false
	end

	local now = os.clock()
	local cooldown = cooldowns[eventName] or 0
	if now - (lastPlayedAt[eventName] or 0) < cooldown then
		return false
	end
	lastPlayedAt[eventName] = now

	local sound = Instance.new("Sound")
	sound.Name = "Feedback_" .. tostring(eventName)
	sound.SoundId = soundId
	sound.Volume = volumes[eventName] or 0.4
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.Parent = SoundService

	SoundService:PlayLocalSound(sound)
	Debris:AddItem(sound, 3)

	return true
end

function FeedbackAudioController.start()
	if started then
		return
	end
	started = true

	Remotes.get(Remotes.Names.FeedbackAudio).OnClientEvent:Connect(function(eventName)
		FeedbackAudioController.play(eventName)
	end)
end

return FeedbackAudioController
