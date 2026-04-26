local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Settings
local highlightsEnabled = true
local currentSpeed = 16
local MIN_SPEED, MAX_SPEED = 16, 200

-- 🎯 FORCE HIGHLIGHT (Fixed for stubborn games)
local function applyHighlight(model, color, name)
	if not model or not model:IsA("Model") then return end
	
	local h = model:FindFirstChild(name)
	if not h then
		h = Instance.new("Highlight")
		h.Name = name
		h.Parent = model
	end
	
	h.FillTransparency = 1 
	h.OutlineTransparency = 0
	h.OutlineColor = color
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.Enabled = highlightsEnabled
end

-- 🟡 MONITORING LOOP
task.spawn(function()
	while true do
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
				if not Players:GetPlayerFromCharacter(obj) then
					applyHighlight(obj, Color3.fromRGB(255, 255, 0), "ArjanESP")
				end
			end
		end
		task.wait(1)
	end
end)

-- 📱 UI THEME
local theme = {
	Bg = Color3.fromRGB(20, 20, 25),
	Accent = Color3.fromRGB(59, 162, 235), -- Blue from photo
	Text = Color3.fromRGB(255, 255, 255),
	Dark = Color3.fromRGB(30, 30, 35)
}

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name, screenGui.ResetOnSpawn = "ArjanHubUI", false

-- 🔵 DRAGGABLE TOGGLE BUTTON
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0.8, 0, 0.1, 0)
toggleBtn.BackgroundColor3 = theme.Accent
toggleBtn.Text = "≡"
toggleBtn.TextColor3 = theme.Text
toggleBtn.TextSize = 35
toggleBtn.Font = Enum.Font.SourceSansBold
local btnCorner = Instance.new("UICorner", toggleBtn)
btnCorner.CornerRadius = UDim.new(0, 8)

-- 📦 MAIN MENU (SMALLER)
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 220, 0, 260)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -130)
mainFrame.BackgroundColor3 = theme.Bg
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "Arjan’s Hub"
title.TextColor3 = theme.Text
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

-- Layout
local list = Instance.new("UIListLayout", mainFrame)
list.Padding = UDim.new(0, 10)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", mainFrame).PaddingTop = UDim.new(0, 50)

-- 🔘 TOGGLE COMPONENT
local function addToggle(text, callback)
	local btn = Instance.new("TextButton", mainFrame)
	btn.Size = UDim2.new(0, 180, 0, 35)
	btn.BackgroundColor3 = theme.Dark
	btn.Text = text .. ": ON"
	btn.TextColor3 = theme.Text
	btn.Font = Enum.Font.SourceSansBold
	Instance.new("UICorner", btn)
	
	local active = true
	btn.Activated:Connect(function()
		active = not active
		btn.Text = text .. (active and ": ON" or ": OFF")
		btn.BackgroundColor3 = active and theme.Dark or Color3.fromRGB(50, 20, 20)
		callback(active)
	end)
end

-- 📏 SLIDER COMPONENT
local function addSlider()
	local sFrame = Instance.new("Frame", mainFrame)
	sFrame.Size = UDim2.new(0, 180, 0, 50)
	sFrame.BackgroundTransparency = 1
	
	local lab = Instance.new("TextLabel", sFrame)
	lab.Size = UDim2.new(1, 0, 0, 20)
	lab.Text = "Speed: 16"
	lab.TextColor3 = theme.Text
	lab.BackgroundTransparency = 1
	
	local bar = Instance.new("Frame", sFrame)
	bar.Size = UDim2.new(1, 0, 0, 4)
	bar.Position = UDim2.new(0, 0, 0.7, 0)
	bar.BackgroundColor3 = theme.Dark
	
	local knob = Instance.new("TextButton", bar)
	knob.Size = UDim2.new(0, 15, 0, 15)
	knob.Position = UDim2.new(0, 0, 0.5, 0)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.BackgroundColor3 = theme.Accent
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
	
	local dragging = false
	knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local percent = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			knob.Position = UDim2.new(percent, 0, 0.5, 0)
			currentSpeed = math.floor(MIN_SPEED + (percent * (MAX_SPEED - MIN_SPEED)))
			lab.Text = "Speed: " .. currentSpeed
		end
	end)
end

-- ⚡ BUILD CONTENT
addToggle("Highlights", function(val) highlightsEnabled = val end)
addSlider()

-- Camera Finder
local camBtn = Instance.new("TextButton", mainFrame)
camBtn.Size = UDim2.new(0, 180, 0, 35)
camBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
camBtn.Text = "Locate Camera"
camBtn.TextColor3 = theme.Text
camBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", camBtn)
camBtn.Activated:Connect(function()
	for _, v in ipairs(workspace:GetDescendants()) do
		if v.Name == "Camera" then applyHighlight(v, Color3.fromRGB(0, 255, 255), "CamESP") end
	end
end)

-- 🖱️ INTERACTION LOGIC
toggleBtn.Activated:Connect(function() mainFrame.Visible = not mainFrame.Visible end)

-- Draggable Toggle Button
local dragToggle, dragStart, startPos
toggleBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragToggle = true; dragStart = input.Position; startPos = toggleBtn.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = false end
end)

-- Speed Loop
task.spawn(function()
	while true do
		local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if h then h.WalkSpeed = currentSpeed end
		task.wait(0.5)
	end
end)
