local ProfileSchema = {
	BaseData = {
		Money = 0,
		Speed = 0,
		Strength = 0,
	},

	Inventory = {
		PlayerHeld = {},
		PlotHeld = {
			[1] = {
				Name = "TungTungSahur",
				Weight = 10,
				Value = 100,
				Rarity = "Common",
				Modifier = "None",
			},
		},
	},
}

return ProfileSchema
