local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type BrainrotInfo = {
	Name: string,
	Weight: number,
	Value: number,
	Rarity: string,
	Modifier: string,
}

local PlayerData = require(script.Parent.PlayerData)

local MaxSlots = 10
local SlotColor = Color3.fromRGB(137, 134, 163)
local SlotColorOccupied = Color3.fromRGB(0, 180, 80)

local Templates = ReplicatedStorage.BrainrotTemplates
local Animations = ReplicatedStorage.Animations

local playerSlots = {}
local playerStorage = {}
local playerTrapdoor = {}

local StorageService = {
	Priority = 3,
	Name = "StorageService",
	Icon = "🧤",
}

local function syncSlotVisual(player, slotIndex)
	local slotParts = playerSlots[player]
	local storage = playerStorage[player]
	if not slotParts or not storage then
		return
	end
	local slotPart = slotParts[slotIndex]
	if not slotPart then
		return
	end
	slotPart.Color = storage[slotIndex] and SlotColorOccupied or SlotColor
end

local function placeModelOnSlot(model, slotPart, player)
	if not model or not slotPart then
		return
	end

	model.Parent = workspace

	model:PivotTo(CFrame.new(0, 1000, 0))
	local bbCF, bbSize = model:GetBoundingBox()
	local pivotToFeet = 1000 - (bbCF.Position.Y - bbSize.Y / 2)

	local slotTopY = slotPart.Position.Y + slotPart.Size.Y / 2
	local pivotY = slotTopY + pivotToFeet
	local pivotPos = Vector3.new(slotPart.Position.X, pivotY, slotPart.Position.Z)

	local trapdoor = playerTrapdoor[player]
	local finalCF
	if trapdoor and trapdoor:IsA("BasePart") then
		local dx = trapdoor.Position.X - slotPart.Position.X
		if math.abs(dx) > 0.01 then
			local sign = dx > 0 and 1 or -1
			finalCF = CFrame.lookAt(pivotPos, pivotPos + Vector3.new(sign, 0, 0))
		else
			finalCF = CFrame.new(pivotPos)
		end
	else
		finalCF = CFrame.new(pivotPos)
	end
	model:PivotTo(finalCF)

	local animation = Animations:FindFirstChild(model.Name)
	local idle = animation:FindFirstChild("Idle")

	local animationController = model:FindFirstChildOfClass("AnimationController")
	local animator = animationController and animationController:FindFirstChildOfClass("Animator")

	if animator and idle then
		local idleTrack: AnimationTrack = animator:LoadAnimation(idle)
		idleTrack.Priority = Enum.AnimationPriority.Action
		idleTrack:Play()
	end

	slotPart.Color = SlotColorOccupied
end

function StorageService:BuildSlots(player: Player, base: Model)
	local slots = {}

	playerTrapdoor[player] = base:FindFirstChild("Trapdoor", true)

	for i = 1, MaxSlots do
		local slotPart = base:FindFirstChild("StorageSlot_" .. i, true)

		if slotPart and slotPart:IsA("BasePart") then
			slots[i] = slotPart

			local existing = slotPart:FindFirstChildOfClass("ProximityPrompt")
			if existing then
				existing:Destroy()
			end

			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Store  [E]"
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.MaxActivationDistance = 6
			prompt.RequiresLineOfSight = false
			prompt.Parent = slotPart

			prompt.Triggered:Connect(function(playerWhoTriggered)
				if playerWhoTriggered ~= player then
					return
				end
			end)
		else
			warn(("[StorageManager] StorageSlot_%d not found in base for %s"):format(i, player.Name))
		end
	end

	playerSlots[player.UserId] = slots

	local playerData = PlayerData:GetData(player)
	if not playerData then
		return
	end

	local storage = playerStorage[player]
	local playerInventory = playerData.Inventory
	local plotHeld = playerInventory.PlotHeld

	if not plotHeld then
		return
	end

	for i, info: BrainrotInfo in plotHeld do
		if i > MaxSlots then
			break
		end

		local slot = slots[i]
		if not slot then
			continue
		end

		local template = Templates:FindFirstChild(info.Name)
		if not template then
			return
		end

		local clone = template:Clone()
		clone.Parent = slot

		storage[i] = {
			model = clone,
			weight = info.Weight,
			value = info.Value,
			rarity = info.Rarity,
			modifier = info.Modifier,
		}

		placeModelOnSlot(clone, slot, player)
		syncSlotVisual(player, i)

		local prompt = slot:FindFirstChildOfClass("ProximityPrompt")
		if prompt then
			prompt.ActionText = "Swap  [E]"
		end
	end
end

function StorageService:Init()
	Players.PlayerAdded:Connect(function(player)
		playerStorage[player] = {}
	end)

	Players.PlayerRemoving:Connect(function(player)
		for _, slot in ipairs(playerSlots[player.UserId] or {}) do
			if slot and slot:IsA("BasePart") then
				local existing = slot:FindFirstChildOfClass("ProximityPrompt")
				if existing then
					existing:Destroy()
				end
			end
		end

		playerSlots[player.UserId] = nil
	end)
end

return StorageService
