local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Bolt = require(ReplicatedStorage:WaitForChild("Libraries"):WaitForChild("Bolt"))

local Network = {
	Money = Bolt.RemoteProperty("Money", 0) :: Bolt.RemoteProperty<number>,
	Speed = Bolt.RemoteProperty("Speed", 0) :: Bolt.RemoteProperty<number>,
	Strength = Bolt.RemoteProperty("Strength", 0) :: Bolt.RemoteProperty<number>,

	CurrencyUpdated = Bolt.ReliableEvent("CurrencyUpdated") :: Bolt.ReliableEvent<>,
}

return Network
