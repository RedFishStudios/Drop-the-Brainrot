local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ReplicatedStorage.Modules.Network)
local PlayerData = require(ServerScriptService.Services.PlayerData)

local CurrencyService = {
	Priority = 2,
	Name = "CurrencyService",
	Icon = "💰",
}

local function setupCurrencies(player: Player)
	local playerData = PlayerData:GetData(player)
	if not playerData then
		warn("Player data not found for player:", player.Name)
		return
	end

	Network.Money:SetFor(player, playerData.BaseData.Money)
	Network.Speed:SetFor(player, playerData.BaseData.Speed)
	Network.Strength:SetFor(player, playerData.BaseData.Strength)
end

function CurrencyService:Increment(player: Player, currencyType: string, amount: number): boolean
	if not player or not currencyType or not amount then
		warn("Invalid parameters for Increment")
		return false
	end

	local playerData = PlayerData:GetData(player)
	if not playerData then
		warn("Player data not found for player:", player.Name)
		return false
	end

	local newAmount = playerData.BaseData[currencyType] + amount
	if newAmount < 0 then
		newAmount = 0
	end

	playerData.BaseData[currencyType] += amount
	Network[currencyType]:SetFor(player, newAmount)
	Network.CurrencyUpdated:FireClient(player)

	return true
end

function CurrencyService:Init()
	Players.PlayerAdded:Connect(function(player)
		setupCurrencies(player)
	end)
end

return CurrencyService
