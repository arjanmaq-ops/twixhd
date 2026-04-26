local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Internal Settings
local highlightsEnabled = true
local currentSpeed = 16
local MIN_SPEED, MAX_SPEED = 16, 200
local CAMERA_NAME = "Camera"

-- 🎯 HIGHLIGHT LOGIC
local function applyHighlight(model, color, name)
	if not model then return end
	for _, child in ipairs(model:GetChildren()) do
		if child:IsA("Highlight") and child.Name ~= name then child:Destroy() end
	end
	local h = model:FindFirstChild(name) or Instance.new("Highlight")
	h.Name, h.Parent = name, model
	h.FillTransparency, h.OutlineTransparency = 1, 0
	h.OutlineColor, h.DepthMode = color, Enum.HighlightDepthMode.AlwaysOnTop
	h.Enabled = highlightsEnabled
	h.Adornee = model
end

-- 🟡 PLAYER & NPC HANDLERS
local function setupPlayer(plr)
	plr.CharacterAdded:Connect(function(char) task.wait(0.5); applyHighlight(char, Color3.fromRGB(255, 255, 0), "PlayerHighlight") end)
	if plr.Character then applyHighlight(plr.Character, Color3.fromRGB(255, 255, 0), "PlayerHighlight") end
end
for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
Players.PlayerAdded:Connect(setupPlayer)

task.spawn(function()
	while true do
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
				applyHighlight(obj, Color3.fromRGB(255, 255, 0), "NPCHighlight")
			end
		end
		task.wait(0.5)
	end
end)

-- ⚡ SPEED LOGIC
local function applySpeed() local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = currentSpeed end end
player.CharacterAdded:Connect(function(c) c:WaitForChild("Humanoid").WalkSpeed = currentSpeed end)
task.spawn(function() while true do applySpeed(); task.wait(1) end end)

-- 📱 UI SETUP
local theme = {
	Bg = Color3.fromRGB(15, 15, 20),
	Container = Color3.fromRGB(25, 25, 30),
	Border = Color3.fromRGB(100, 100, 100),
	Accent = Color3.fromRGB(0, 170, 255),
	Text = Color3.fromRGB(255, 255, 255),
	SliderBall = Color3.fromRGB(255, 165, 0)
}

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name, screenGui.ResetOnSpawn = "UtilityUI", false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 320, 0, 380)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
mainFrame.BackgroundColor3 = theme.Bg
mainFrame.BorderSizePixel = 0
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 10)
title.Text = "Arjan’s Hub"
title.TextColor3 = theme.Text
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 24

local tabBar = Instance.new("Frame", mainFrame)
tabBar.Size = UDim2.new(1, -40, 0, 30)
tabBar.Position = UDim2.new(0, 20, 0, 70)
tabBar.BackgroundTransparency = 1

local tabName = Instance.new("TextLabel", tabBar)
tabName.Size = UDim2.new(0, 70, 1, 0)
tabName.Text = "Visual"
tabName.TextColor3 = theme.Accent
tabName.BackgroundTransparency = 1
tabName.Font = Enum.Font.SourceSansBold
tabName.TextSize = 16

local tabUnderline = Instance.new("Frame", tabName)
tabUnderline.Size = UDim2.new(1, 0, 0, 2)
tabUnderline.Position = UDim2.new(0, 0, 1, 0)
tabUnderline.BackgroundColor3 = theme.Accent
tabUnderline.BorderSizePixel = 0

local container = Instance.new("ScrollingFrame", mainFrame)
container.Size = UDim2.new(1, -40, 1, -130)
container.Position = UDim2.new(0, 20, 0, 110)
container.BackgroundTransparency = 1
container.ScrollBarThickness = 0
container.BorderSizePixel = 0
Instance.new("UIListLayout", container).Padding = UDim.new(0, 15)

-- Modern Toggle
local function createToggle(text, startState, onActivated)
	local tFrame = Instance.new("Frame", container)
	tFrame.Size = UDim2.new(1, -10, 0, 70)
	tFrame.BackgroundColor3 = theme.Container
	Instance.new("UICorner", tFrame).CornerRadius = UDim.new(0, 10)
	local border = Instance.new("UIStroke", tFrame)
	border.Color, border.Thickness, border.ApplyStrokeMode = theme.Border, 1, Enum.ApplyStrokeMode.Border

	local tLabel = Instance.new("TextLabel", tFrame)
	tLabel.Size, tLabel.Position = UDim2.new(1, -80, 1, 0), UDim2.new(0, 20, 0, 0)
	tLabel.Text, tLabel.TextColor3, tLabel.BackgroundTransparency = text, theme.Text, 1
	tLabel.Font, tLabel.TextSize, tLabel.TextXAlignment = Enum.Font.SourceSansBold, 18, Enum.TextXAlignment.Left

	local tBtn = Instance.new("TextButton", tFrame)
	tBtn.Size, tBtn.Position = UDim2.new(0, 50, 0, 26), UDim2.new(1, -70, 0.5, -13)
	tBtn.BackgroundColor3, tBtn.Text = startState and theme.Accent or Color3.fromRGB(60, 60, 65), ""
	Instance.new("UICorner", tBtn).CornerRadius = UDim.new(1, 0)

	local ball = Instance.new("Frame", tBtn)
	ball.Size = UDim2.new(0, 20, 0, 20)
	ball.Position = startState and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
	ball.BackgroundColor3 = theme.Text
	Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)

	local state = startState
	tBtn.Activated:Connect(function()
		state = not state
		local targetPos = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
		local targetColor = state and theme.Accent or Color3.fromRGB(60, 60, 65)
		TweenService:Create(ball, TweenInfo.new(0.2), {Position = targetPos}):Play()
		TweenService:Create(tBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
		onActivated(state)
	end)
end

-- Slider
local function createSlider()
	local sFrame = Instance.new("Frame", container)
	sFrame.Size = UDim2.new(1, -10, 0, 100)
	sFrame.BackgroundColor3 = theme.Container
	Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 10)
	local border = Instance.new("UIStroke", sFrame)
	border.Color, border.Thickness, border.ApplyStrokeMode = theme.Border, 1, Enum.ApplyStrokeMode.Border

	local sLabel = Instance.new("TextLabel", sFrame)
	sLabel.Size, sLabel.Position = UDim2.new(1, -20, 0, 40), UDim2.new(0, 20, 0, 10)
	sLabel.Text, sLabel.TextColor3, sLabel.BackgroundTransparency = "Walkspeed: 16", theme.Text, 1
	sLabel.Font, sLabel.TextSize, sLabel.TextXAlignment = Enum.Font.SourceSansBold, 18, Enum.TextXAlignment.Left

	local sliderBar = Instance.new("Frame", sFrame)
	sliderBar.Size, sliderBar.Position = UDim2.new(1, -40, 0, 4), UDim2.new(0, 20, 0, 70)
	sliderBar.BackgroundColor3, sliderBar.BorderSizePixel = Color3.fromRGB(60, 60, 65), 0
	Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("TextButton", sliderBar)
	knob.Size, knob.Position, knob.AnchorPoint = UDim2.new(0, 24, 0, 24), UDim2.new(0, 0, 0.5, 0), Vector2.new(0.5, 0.5)
	knob.BackgroundColor3, knob.Text = theme.SliderBall, ""
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local dragging = false
	knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local percent = math.clamp((i.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
			knob.Position = UDim2.new(percent, 0, 0.5, 0)
			currentSpeed = math.floor(MIN_SPEED + (percent * (MAX_SPEED - MIN_SPEED)))
			sLabel.Text = "Walkspeed: " .. currentSpeed; applySpeed()
		end
	end)
end

-- Button
local function createButton(text, onActivated)
	local bFrame = Instance.new("Frame", container)
	bFrame.Size = UDim2.new(1, -10, 0, 70)
	bFrame.BackgroundColor3 = theme.Container
	Instance.new("UICorner", bFrame).CornerRadius = UDim.new(0, 10)
	local border = Instance.new("UIStroke", bFrame)
	border.Color, border.Thickness, border.ApplyStrokeMode = theme.Border, 1, Enum.ApplyStrokeMode.Border

	local b = Instance.new("TextButton", bFrame)
	b.Size, b.Position, b.AnchorPoint = UDim2.new(1, -40, 1, -20), UDim2.new(0.5, 0, 0.5, 0), Vector2.new(0.5, 0.5)
	b.BackgroundColor3, b.Text, b.TextColor3 = Color3.fromRGB(0, 120, 180), text, theme.Text
	b.Font, b.TextSize = Enum.Font.SourceSansBold, 20
	Instance.new("UICorner", b)
	b.Activated:Connect(onActivated)
end

-- 🖱️ DRAGGABLE
local dragToggle, dragStart, startPos
title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragToggle = true; dragStart = input.Position; startPos = mainFrame.Position
		input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end)
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Populating Hub
createToggle("Global Highlights", highlightsEnabled, function(state) highlightsEnabled = state end)
createSlider()
createButton("Locate Camera", function()
	for _, o in ipairs(workspace:GetDescendants()) do if o.Name == CAMERA_NAME then applyHighlight(o, Color3.fromRGB(0, 255, 255), "CameraHighlight") end end 
end)
