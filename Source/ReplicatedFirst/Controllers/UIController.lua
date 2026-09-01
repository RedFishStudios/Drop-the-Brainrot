local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 30)
local main = playerGui:WaitForChild("Main", 30)
local hud = main:WaitForChild("HUD", 30)
local buttons = hud:WaitForChild("Buttons", 30)

local UIController = {
	Priority = 1,
	Name = "UIController",
	Icon = "🧤",
}

function UIController:OpenFrame(frameName: string)
	local frame = main:FindFirstChild(frameName)
	if not frame then
		print("UIController:OpenFrame() - No frame found for " .. frameName)
		return
	end

	SoundService:PlayLocalSound(SoundService.whoosh)

	frame.Visible = true
	TweenService:Create(frame.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1,
	}):Play()

	local UIBlur = Lighting:FindFirstChild("UiBlur")
	if UIBlur then
		TweenService:Create(UIBlur, TweenInfo.new(0.25), {
			Size = 24,
		}):Play()
	end

	TweenService:Create(camera, TweenInfo.new(0.25), {
		FieldOfView = 90,
	}):Play()
end

function UIController:CloseFrame(frameName: string)
	local frame = main:FindFirstChild(frameName)
	if not frame then
		print("UIController:CloseFrame() - No frame found for " .. frameName)
		return
	end

	SoundService:PlayLocalSound(SoundService.whoosh)

	TweenService:Create(frame.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Scale = 0,
	}):Play()

	task.delay(0.25, function()
		frame.Visible = false
	end)

	local UIBlur = Lighting:FindFirstChild("UiBlur")
	if UIBlur then
		TweenService:Create(UIBlur, TweenInfo.new(0.25), {
			Size = 0,
		}):Play()
	end

	TweenService:Create(camera, TweenInfo.new(0.25), {
		FieldOfView = 70,
	}):Play()
end

function UIController:CloseAllOtherFrames(excludeFrame: string)
	for _, frame in main:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		if frame.Name == excludeFrame then
			continue
		end

		if not string.find(frame.Name, "Frame") then
			continue
		end

		if frame.Visible then
			self:CloseFrame(frame.Name)
		end
	end
end

function UIController:ButtonAnimation()
	for _, button in playerGui:GetDescendants() do
		if button:IsA("TextButton") or button:IsA("ImageButton") then
			if not button:FindFirstChild("UIScale") then
				local uiScale = Instance.new("UIScale")
				uiScale.Parent = button
				uiScale.Scale = 1
			end

			button.MouseEnter:Connect(function()
				TweenService:Create(button.UIScale, TweenInfo.new(0.1), { Scale = 1.1 }):Play()
				SoundService:PlayLocalSound(SoundService.hover)
			end)

			button.MouseLeave:Connect(function()
				TweenService:Create(button.UIScale, TweenInfo.new(0.1), { Scale = 1 }):Play()
			end)
		end
	end
end

function UIController:InitButtons()
	for _, button in buttons:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		button.Activated:Connect(function()
			local frameName = button.Name .. "Frame"

			self:CloseAllOtherFrames(frameName)
			self:OpenFrame(frameName)

			SoundService:PlayLocalSound(SoundService.whoosh)
			SoundService:PlayLocalSound(SoundService.down)
		end)
	end

	for _, button in playerGui:GetDescendants() do
		if not button:IsA("TextButton") and not button:IsA("ImageButton") then
			continue
		end

		if button.Name ~= "X" then
			continue
		end

		button.Activated:Connect(function()
			local frame = button.Parent.Parent

			if not frame then
				print("UIController:InitButtons() - No frame found for button " .. button.Name)
				return
			end

			SoundService:PlayLocalSound(SoundService.down)
			SoundService:PlayLocalSound(SoundService.whoosh)

			self:CloseFrame(frame.Name)

			task.delay(0.25, function()
				frame.Visible = false
			end)
		end)
	end
end

function UIController:Init()
	task.spawn(function()
		self:InitButtons()
		self:ButtonAnimation()
	end)
end

return UIController
