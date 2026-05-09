local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponDefinitions = require(Shared:WaitForChild("WeaponDefinitions"))

local EnemyService = require(script.Parent:WaitForChild("EnemyService"))
local ExperienceService = require(script.Parent:WaitForChild("ExperienceService"))
local PlayerStateService = require(script.Parent:WaitForChild("PlayerStateService"))

local CombatService = {}

local projectileFolder
local attackTimers = {}
local projectiles = {}

local function getProjectileFolder()
	if projectileFolder then
		return projectileFolder
	end

	projectileFolder = Workspace:FindFirstChild("Projectiles")
	if not projectileFolder then
		projectileFolder = Instance.new("Folder")
		projectileFolder.Name = "Projectiles"
		projectileFolder.Parent = Workspace
	end

	return projectileFolder
end

local function createExplosionFeedback(position, radius)
	local feedback = Instance.new("Part")
	feedback.Name = "ExplosionFeedback"
	feedback.Anchored = true
	feedback.CanCollide = false
	feedback.CanQuery = false
	feedback.CanTouch = false
	feedback.Material = Enum.Material.SmoothPlastic
	feedback.Color = Color3.fromRGB(255, 196, 64)
	feedback.Transparency = 0.95
	feedback.Size = Vector3.new(radius * 0.25, 0.1, radius * 0.25)
	feedback.Position = position + Vector3.new(0, 0.15, 0)
	feedback.Parent = getProjectileFolder()

	local decal = Instance.new("Decal")
	decal.Name = "ExplosionImage"
	decal.Face = Enum.NormalId.Top
	decal.Texture = WeaponDefinitions.BasicBolt.ExplosionFeedbackImage
	decal.Transparency = 0.05
	decal.Parent = feedback

	local duration = WeaponDefinitions.BasicBolt.ExplosionFeedbackDuration
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(feedback, tweenInfo, {
		Size = Vector3.new(radius * 2, 0.1, radius * 2),
		Transparency = 1,
	}):Play()
	TweenService:Create(decal, tweenInfo, {
		Transparency = 1,
	}):Play()

	Debris:AddItem(feedback, duration + 0.1)
end

local function applyExplosion(player, position, directHitEnemy, directDamage)
	local state = PlayerStateService.getState(player)
	local explosion = state and state.ExplosiveBolt
	if not explosion then
		return
	end

	local damage = math.max(1, math.floor((directDamage * explosion.DamageMultiplier) + 0.5))
	for _, enemy in ipairs(EnemyService.getEnemiesInRadius(position, explosion.Radius, directHitEnemy)) do
		local killInfo = EnemyService.damage(enemy, damage)
		ExperienceService.awardKill(player, killInfo)
	end

	createExplosionFeedback(position, explosion.Radius)
end

local function createProjectile(player, target, damage, speed)
	local root = PlayerStateService.getRoot(player)
	if not root or not target or not target.Parent then
		return
	end

	local projectile = Instance.new("Part")
	projectile.Name = "BasicBolt"
	projectile.Shape = Enum.PartType.Ball
	projectile.Size = Vector3.new(1.2, 1.2, 1.2)
	projectile.Color = Color3.fromRGB(255, 232, 120)
	projectile.Material = Enum.Material.Neon
	projectile.Anchored = true
	projectile.CanCollide = false
	projectile.Position = root.Position + Vector3.new(0, 2, 0)
	projectile.Parent = getProjectileFolder()

	projectiles[projectile] = {
		Owner = player,
		Target = target,
		Damage = damage,
		Speed = speed,
		CreatedAt = os.clock(),
	}
end

local function updateProjectiles(deltaTime)
	for projectile, data in pairs(projectiles) do
		if not projectile.Parent or not data.Target.Parent then
			projectiles[projectile] = nil
			projectile:Destroy()
			continue
		end

		if os.clock() - data.CreatedAt > 2.5 then
			projectiles[projectile] = nil
			projectile:Destroy()
			continue
		end

		local targetPosition = data.Target.Position
		local direction = targetPosition - projectile.Position

		if direction.Magnitude <= 2.5 then
			local impactPosition = data.Target.Position
			local killInfo = EnemyService.damage(data.Target, data.Damage)
			ExperienceService.awardKill(data.Owner, killInfo)
			applyExplosion(data.Owner, impactPosition, data.Target, data.Damage)
			projectiles[projectile] = nil
			projectile:Destroy()
			continue
		end

		projectile.Position += direction.Unit * data.Speed * deltaTime
	end
end

local function tryAttack(player, deltaTime)
	local state = PlayerStateService.getState(player)
	local root = PlayerStateService.getRoot(player)
	if not state or not state.Alive or not root then
		return
	end

	attackTimers[player] = (attackTimers[player] or 0) + deltaTime
	if attackTimers[player] < state.AttackInterval then
		return
	end

	local target = EnemyService.getNearestEnemy(root.Position, state.AttackRange)
	if not target then
		return
	end

	attackTimers[player] = 0
	createProjectile(player, target, state.AttackDamage, WeaponDefinitions.BasicBolt.ProjectileSpeed)
end

function CombatService.start()
	getProjectileFolder()

	RunService.Heartbeat:Connect(function(deltaTime)
		if PlayerStateService.isPaused() then
			return
		end

		updateProjectiles(deltaTime)

		for _, player in ipairs(PlayerStateService.getAlivePlayers()) do
			tryAttack(player, deltaTime)
		end
	end)
end

return CombatService
