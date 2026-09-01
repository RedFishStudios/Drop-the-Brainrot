local Players = game:GetService("Players")
local MaxSlots = 10

local playerSlots = {}

local StorageService = {
	Priority = 3,
	Name = "StorageService",
	Icon = "🧤",
}

function StorageService:BuildSlots(player: Player, base: Model)
	local slots = {}

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
end

function StorageService:Init()
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
