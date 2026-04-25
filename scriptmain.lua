local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local highlightsEnabled = true
local bellEnabled = true
local currentSpeed = 16
local MIN_SPEED, MAX_SPEED = 16, 200
local CAMERA_NAME, DIVEBELL_NAME = "Camera", "DIVEBELL"

-- 🎯 STABLE HIGHLIGHT FUNCTION
local function applyHighlight(model, color, name, isBell)
	if not model then return end
	for _, child in ipairs(model:GetChildren()) do
		if child:IsA("Highlight") and child.Name ~= name then child:Destroy() end
	end
	local h = model:FindFirstChild(name) or Instance.new("Highlight")
	h.Name, h.Parent = name, model
	h.FillTransparency, h.OutlineTransparency = 1, 0
	h.OutlineColor, h.DepthMode = color, Enum.HighlightDepthMode.AlwaysOnTop
	
	-- Logic to check if this specific highlight should be visible
	if isBell then
		h.Enabled = (highlightsEnabled and bellEnabled)
	else
		h.Enabled = highlightsEnabled
	end
	h.Adornee = model
end

-- 🟡 PLAYER HANDLER
local function setupPlayer(plr)
	plr.CharacterAdded:Connect(function(char) task.wait(0.5); applyHighlight(char, Color3.fromRGB(255, 255, 0), "PlayerHighlight", false) end)
	if plr.Character then applyHighlight(plr.Character, Color3.fromRGB(255, 255, 0), "PlayerHighlight", false) end
end
for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
Players.PlayerAdded:Connect(setupPlayer)

-- 🔄 CONTINUOUS OVERRIDE
task.spawn(function()
	while true do
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
				applyHighlight(obj, Color3.fromRGB(255, 255, 0), "NPCHighlight", false)
			end
			if obj.Name:upper() == DIVEBELL_NAME or obj.Name == "DiveBell" then
				applyHighlight(obj, Color3.fromRGB(255, 165, 0), "BellHighlight", true)
			end
		end
		task.wait(0.3)
	end
end)

-- 📱 UI SETUP
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name, screenGui.ResetOnSpawn = "UtilityUI", false

local function createBtn(text, pos, color)
	local b = Instance.new("TextButton", screenGui)
	b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0, 160, 0, 45), pos, text, color
	b.TextColor3, b.TextScaled, b.Font = Color3.new(1,1,1), true, Enum.Font.SourceSansBold
	Instance.new("UICorner", b)
	return b
end

-- LEFT SIDE BUTTONS
local cBtn = createBtn("Locate Camera", UDim2.new(0, 20, 0, 60), Color3.fromRGB(0, 150, 200))
local hBtn = createBtn("Highlights: ON", UDim2.new(0, 20, 0, 110), Color3.fromRGB(30, 30, 30))

-- RIGHT SIDE BUTTON (Divebell Toggle)
-- AnchorPoint 1,0 makes it easier to position relative to the right edge
local bBtn = createBtn("Divebell: ON", UDim2.new(1, -180, 0, 60), Color3.fromRGB(200, 100, 0))

-- SLIDER (Left side)
local sliderBack = Instance.new("Frame", screenGui)
sliderBack.Size, sliderBack.Position, sliderBack.BackgroundColor3 = UDim2.new(0, 160, 0, 50), UDim2.new(0, 20, 0, 160), Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", sliderBack)
local speedLabel = Instance.new("TextLabel", sliderBack)
speedLabel.Size, speedLabel.BackgroundTransparency, speedLabel.Text, speedLabel.TextColor3 = UDim2.new(1, 0, 0, 25), 1, "Speed: 16", Color3.new(1,1,1)
local sliderBar = Instance.new("Frame", sliderBack)
sliderBar.Size, sliderBar.Position, sliderBar.BackgroundColor3 = UDim2.new(0.8, 0, 0, 4), UDim2.new(0.1, 0, 0.75, 0), Color3.fromRGB(80, 80, 80)
local knob = Instance.new("TextButton", sliderBar)
knob.Size, knob.Position, knob.AnchorPoint, knob.BackgroundColor3, knob.Text = UDim2.new(0, 20, 0, 20), UDim2.new(0, 0, 0.5, 0), Vector2.new(0.5, 0.5), Color3.fromRGB(255, 165, 0), ""
Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

-- ⚡ LOGIC UPDATES
local function applySpeed() local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = currentSpeed end end

bBtn.Activated:Connect(function()
	bellEnabled = not bellEnabled
	bBtn.Text = bellEnabled and "Divebell: ON" or "Divebell: OFF"
end)

hBtn.Activated:Connect(function()
	highlightsEnabled = not highlightsEnabled
	hBtn.Text = highlightsEnabled and "Highlights: ON" or "Highlights: OFF"
end)

cBtn.Activated:Connect(function() 
	for _, o in ipairs(workspace:GetDescendants()) do 
		if o.Name == CAMERA_NAME then applyHighlight(o, Color3.fromRGB(0, 255, 255), "CameraHighlight", false) end 
	end 
end)

-- SLIDER DRAGGING
local dragging = false
local function updateSpeed(input)
	local percent = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
	knob.Position = UDim2.new(percent, 0, 0.5, 0)
	currentSpeed = math.floor(MIN_SPEED + (percent * (MAX_SPEED - MIN_SPEED)))
	speedLabel.Text = "Speed: " .. currentSpeed; applySpeed()
end
knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then updateSpeed(i) end end)

task.spawn(function() while true do applySpeed(); task.wait(1) end end)
