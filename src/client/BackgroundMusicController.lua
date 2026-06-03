local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local AudioAssets = require(Shared:WaitForChild("AudioAssets"))

local BackgroundMusicController = {}

local MUSIC_NAME = "GoblinBackgroundMusic"
local MUSIC_SLOT_NAMES = {
	MUSIC_NAME .. "_A",
	MUSIC_NAME .. "_B",
}
local MUSIC_VOLUME = 0.28
local FADE_SECONDS = 1.5
local LOAD_TIMEOUT_SECONDS = 8

local started = false

local function getBackgroundMusicId()
	local audio = AudioAssets.v1_0
	local music = audio and audio.music
	if type(music) ~= "table" then
		return nil
	end

	return music.background_music_sample
end

local function tweenVolume(sound, volume, duration)
	local tween = TweenService:Create(sound, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Volume = volume,
	})
	tween:Play()
	return tween
end

local function clearExistingMusicSounds()
	local legacySound = SoundService:FindFirstChild(MUSIC_NAME)
	if legacySound and legacySound:IsA("Sound") then
		legacySound:Destroy()
	end

	for _, name in MUSIC_SLOT_NAMES do
		local sound = SoundService:FindFirstChild(name)
		if sound and sound:IsA("Sound") then
			sound:Destroy()
		end
	end
end

local function createMusicSound(name, soundId)
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = soundId
	sound.Looped = false
	sound.Volume = 0
	sound.Parent = SoundService
	return sound
end

local function waitForLength(sound)
	local startedAt = os.clock()
	while sound.Parent and sound.TimeLength <= 0 and os.clock() - startedAt < LOAD_TIMEOUT_SECONDS do
		task.wait(0.1)
	end

	return sound.TimeLength
end

local function playFromStart(sound)
	sound.Volume = 0
	sound.TimePosition = 0
	sound:Play()
	tweenVolume(sound, MUSIC_VOLUME, FADE_SECONDS)
end

local function fadeOutAndStop(sound)
	tweenVolume(sound, 0, FADE_SECONDS)
	task.delay(FADE_SECONDS, function()
		if sound.Parent and sound.IsPlaying then
			sound:Stop()
		end
	end)
end

local function runCrossfadeLoop(sounds)
	local currentIndex = 1
	playFromStart(sounds[currentIndex])

	while started do
		local currentSound = sounds[currentIndex]
		local currentLength = waitForLength(currentSound)
		if currentLength <= FADE_SECONDS * 2 then
			currentSound.Looped = true
			currentSound.Volume = MUSIC_VOLUME
			return
		end

		task.wait(math.max(0.1, currentLength - FADE_SECONDS))
		if not started then
			return
		end

		local nextIndex = if currentIndex == 1 then 2 else 1
		local nextSound = sounds[nextIndex]
		playFromStart(nextSound)
		fadeOutAndStop(currentSound)
		currentIndex = nextIndex
	end
end

function BackgroundMusicController.start()
	if started then
		return false
	end
	started = true

	local soundId = getBackgroundMusicId()
	if type(soundId) ~= "string" or soundId == "" then
		warn("[goblin] Background music asset is not available")
		return false
	end

	clearExistingMusicSounds()

	local sounds = {
		createMusicSound(MUSIC_SLOT_NAMES[1], soundId),
		createMusicSound(MUSIC_SLOT_NAMES[2], soundId),
	}
	task.spawn(runCrossfadeLoop, sounds)

	return true
end

return BackgroundMusicController
