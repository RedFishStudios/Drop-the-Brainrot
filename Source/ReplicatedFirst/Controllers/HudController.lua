local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"))
local AbbreviateModule = require(ReplicatedStorage:WaitForChild("Utils"):WaitForChild("AbbreviateUtil"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 30)
local main = playerGui:WaitForChild("Main", 30)
local hud = main:WaitForChild("HUD", 30)
local leftHud = hud:WaitForChild("LeftHud", 30)

local HudController = {
	Priority = 2,
	Name = "HudController",
	Icon = "🧤",
}

local function updateHud()
	local money = Network.Money:Get()
	local speed = Network.Speed:Get()
	local strength = Network.Strength:Get()

	leftHud.Money.TextLabel.Text = AbbreviateModule:AbbreviateNumbers(money)
	leftHud.Speed.TextLabel.Text = AbbreviateModule:AbbreviateNumbers(speed)
	leftHud.Strength.TextLabel.Text = AbbreviateModule:AbbreviateNumbers(strength)
end

function HudController:Init()
	updateHud()
	Network.CurrencyUpdated.OnClientEvent:Connect(updateHud)
end

return HudController
