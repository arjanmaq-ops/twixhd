local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local highlightsEnabled = true
local currentSpeed = 16
local MIN_SPEED = 16
local MAX_SPEED = 200

local CAMERA_NAME = "Camera"
local DIVEBELL_NAME = "DIVEBELL"

-- 🎯 STABLE HIGHLIGHT FUNCTION
local function applyHighlight(model, color, name)
	if not model then return end
	
	-- Clear competing highlights
	for _, child in ipairs(model:GetChildren()) do
		if child:IsA("Highlight") and child.Name ~= name then
			child:Destroy()
		end
	end

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
	h.Adornee = model
end

-- 🟡 PLAYER HANDLER
local function setupPlayer(plr)
	plr.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		applyHighlight(char, Color3.fromRGB(255, 255, 0), "PlayerHighlight")
	end)
	if plr.Character then applyHighlight(plr.Character, Color3.fromRGB(255, 255, 0), "PlayerHighlight") end
end
for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
Players.PlayerAdded:Connect(setupPlayer)

-- 🔄 CONTINUOUS OVERRIDE (NPCs & Divebell)
task.spawn(function()
	while true do
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
				if not Players:GetPlayerFromCharacter(obj) then
					applyHighlight(obj, Color3.fromRGB(255, 255, 0), "NPCHighlight")
				end
			end
			if obj.Name:upper() == DIVEBELL_NAME or obj.Name == "DiveBell" then
				applyHighlight(obj, Color3.fromRGB(255, 165, 0), "BellHighlight")
			end
		end
		task.wait(0.3)
	end
end)

-- 📱 UI SETUP
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "UtilityUI"
screenGui.ResetOnSpawn = false

local cBtn = Instance.new("TextButton", screenGui)
cBtn.Size = UDim2.new(0, 160, 0, 45)
cBtn.Position = UDim2.new(0, 20, 0, 60)
cBtn.Text = "Locate Camera"
cBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
cBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cBtn.TextScaled = true
cBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", cBtn)

local hBtn = Instance.new("TextButton", screenGui)
hBtn.Size = UDim2.new(0, 160, 0, 45)
hBtn.Position = UDim2.new(0, 20, 0, 110)
hBtn.Text = "Highlights: ON"
hBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
hBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hBtn.TextScaled = true
hBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", hBtn)

local sliderBack = Instance.new("Frame", screenGui)
sliderBack.Size = UDim2.new(0, 160, 0, 50)
sliderBack.Position = UDim2.new(0, 20, 0, 160)
sliderBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", sliderBack)

local speedLabel = Instance.new("TextLabel", sliderBack)
speedLabel.Size = UDim2.new(1, 0, 0, 25)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: 16"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.SourceSansBold
speedLabel.TextSize = 16

local sliderBar = Instance.new("Frame", sliderBack)
sliderBar.Size = UDim2.new(0.8, 0, 0, 4)
sliderBar.Position = UDim2.new(0.1, 0, 0.75, 0)
sliderBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

local knob = Instance.new("TextButton", sliderBar)
knob.Size = UDim2.new(0, 20, 0, 20)
knob.Position = UDim2.new(0, 0, 0.5, 0)
knob.AnchorPoint = Vector2.new(0.5, 0.5)
knob.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
knob.Text = ""
Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

-- ⚡ SPEED LOGIC
local function applySpeed()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = currentSpeed end
end

player.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid")
	hum.WalkSpeed = currentSpeed
end)

local dragging = false
local function updateSpeed(input)
	local percent = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
	knob.Position = UDim2.new(percent, 0, 0.5, 0)
	currentSpeed = math.floor(MIN_SPEED + (percent * (MAX_SPEED - MIN_SPEED)))
	speedLabel.Text = "Speed: " .. tostring(currentSpeed)
	applySpeed()
end

knob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSpeed(input) end
end)

cBtn.Activated:Connect(function()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj.Name == CAMERA_NAME then applyHighlight(obj, Color3.fromRGB(0, 255, 255), "CameraHighlight") end
	end
end)

hBtn.Activated:Connect(function()
	highlightsEnabled = not highlightsEnabled
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Highlight") then v.Enabled = highlightsEnabled end
	end
	hBtn.Text = highlightsEnabled and "Highlights: ON" or "Highlights: OFF"
end)

task.spawn(function()
	while true do
		applySpeed()
		task.wait(1) 
	end
end)
