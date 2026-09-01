local Players = game:GetService("Players")

local StorageService = require(script.Parent.StorageService)

local BasesFolder = workspace:WaitForChild("Bases")

local claimedBases = {}

local PlotService = {
	Priority = 2,
	Name = "PlotService",
	Icon = "🧤",
}

local function getAllBases()
	local bases = {}
	for _, child in ipairs(BasesFolder:GetChildren()) do
		if child:IsA("Model") then
			table.insert(bases, child)
		end
	end
	return bases
end

local function teleportToBase(player: Player, base: Model)
	local character = player.Character
	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local spawn = base:FindFirstChildOfClass("SpawnLocation") or base:FindFirstChild("Trapdoor", true)

	if humanoidRootPart and spawn then
		local spawnPos = spawn:IsA("BasePart") and spawn.Position
			or (spawn.PrimaryPart and spawn.PrimaryPart.Position)
			or Vector3.new(0, 5, 0)
		humanoidRootPart.CFrame = CFrame.new(spawnPos + Vector3.new(0, 5, 0))
	end
end

local function claimBase(player, base)
	base:SetAttribute("OwnerUserId", player.UserId)
	base.Name = "Base_" .. player.UserId

	local spawnLoc = base:FindFirstChildOfClass("SpawnLocation")
	if spawnLoc then
		spawnLoc.Enabled = true
		spawnLoc.Neutral = false
		spawnLoc.TeamColor = player.TeamColor
	end

	StorageService:BuildSlots(player, base)

	-- if CaveManager then
	-- 	CaveManager.SetupDropButton(base, player)
	-- end

	print(("[BaseManager] %s assigned to %s"):format(player.Name, base.Name))
	-- updateBaseBillboard(base, player.Name .. "'s Base", Color3.fromRGB(100, 255, 100), player.UserId)
	claimedBases[player.UserId] = { model = base }
end

local function assignBaseToPlayer(player)
	if claimedBases[player.UserId] then
		return claimedBases[player.UserId].model
	end

	local assignedBase = nil
	for _, base in ipairs(getAllBases()) do
		local owner = base:GetAttribute("OwnerUserId")
		if not owner or owner == 0 then
			base:SetAttribute("OwnerUserId", player.UserId)
			assignedBase = base
			break
		end
	end

	if not assignedBase then
		warn("[BaseManager] No free bases for " .. player.Name)
		return
	end

	claimBase(player, assignedBase)

	player.CharacterAdded:Connect(function()
		task.delay(0.5, function()
			teleportToBase(player, assignedBase)
		end)
		-- task.delay(1.5, function()
		-- 	restoreStoredBrainrots(player, assignedBase)
		-- end)
	end)

	if player.Character then
		task.delay(0.5, function()
			teleportToBase(player, assignedBase)
		end)
		-- task.delay(1.5, function()
		-- 	restoreStoredBrainrots(player, assignedBase)
		-- end)
	end

	return assignedBase
end

local function onPlayerAdded(player)
	local base = assignBaseToPlayer(player)

	if not base then
		warn("[BaseManager] No free base for " .. player.Name)
		return
	end
end

local function onPlayerRemoving(player)
	local info = claimedBases[player.UserId]
	if info and info.model then
		local spawnLoc = info.model:FindFirstChildOfClass("SpawnLocation")
		if spawnLoc then
			spawnLoc.Enabled = false
		end
		info.model:SetAttribute("OwnerUserId", 0)
		info.model.Name = "Base"
	end

	claimedBases[player.UserId] = nil
end

function PlotService.GetBase(player: Player)
	local info = claimedBases[player.UserId]
	return info and info.model or nil
end

function PlotService.GetPathStart()
	return Vector3.new(-8, 62, -700)
end

function PlotService:Init()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
end

return PlotService
