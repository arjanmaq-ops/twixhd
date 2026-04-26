local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- 🔒 INITIAL SETTINGS (OFF BY DEFAULT)
local espActive = false
local walkSpeedActive = false
local currentSpeed = 16
local MIN_SPEED, MAX_SPEED = 16, 200

-- 🎯 UNIVERSAL HIGHLIGHTER (Self, Players, NPCs, Monsters)
local function applyHighlight(model, color, name)
    if not model:IsA("Model") then return end
    
    local h = model:FindFirstChild(name)
    if not h then
        h = Instance.new("Highlight")
        h.Name = name
        h.Parent = model
    end
    
    h.Enabled = espActive
    h.FillTransparency = 1 
    h.OutlineTransparency = 0
    h.OutlineColor = color
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

-- 🟡 MONITORING & SPAWN DETECTION
RunService.RenderStepped:Connect(function()
    if espActive then
        -- Scans workspace for everything with a Humanoid (handles new spawns)
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
                -- Highlights EVERYONE (including you)
                applyHighlight(obj, Color3.fromRGB(255, 255, 0), "ArjanHighlighter")
            end
        end
    else
        -- Cleanup when OFF
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "ArjanHighlighter" or v.Name == "CamHighlighter" then v:Destroy() end
        end
    end
    
    -- Speed Logic
    local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if h then
        h.WalkSpeed = walkSpeedActive and currentSpeed or 16
    end
end)

-- 📱 UI THEME
local theme = {
    Bg = Color3.fromRGB(20, 20, 25),
    Accent = Color3.fromRGB(59, 162, 235), 
    Text = Color3.fromRGB(255, 255, 255)
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ArjanHubUI"
local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

-- 🔵 DRAGGABLE TOGGLE BUTTON (Matches photo)
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
toggleBtn.BackgroundColor3 = theme.Accent
toggleBtn.Text = "≡"
toggleBtn.TextColor3 = theme.Text
toggleBtn.TextSize = 40
toggleBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 12)

-- 📦 MENU FRAME (Compact)
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 210, 0, 310) 
mainFrame.Position = UDim2.new(0.5, -105, 0.5, -155)
mainFrame.BackgroundColor3 = theme.Bg
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)

local list = Instance.new("UIListLayout", mainFrame)
list.Padding = UDim.new(0, 10)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", mainFrame).PaddingTop = UDim.new(0, 15)

-- 🔘 TOGGLE COMPONENT
local function createToggle(text, callback)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(0, 180, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = theme.Text
    btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn)
    
    local state = false
    btn.Activated:Connect(function()
        state = not state
        btn.Text = text .. (state and ": ON" or ": OFF")
        btn.BackgroundColor3 = state and theme.Accent or Color3.fromRGB(45, 45, 50)
        callback(state)
    end)
end

createToggle("ESP (Universal)", function(s) espActive = s end)
createToggle("Speed Mod", function(s) walkSpeedActive = s end)

-- 📏 SPEED SLIDER
local sFrame = Instance.new("Frame", mainFrame)
sFrame.Size = UDim2.new(0, 180, 0, 50)
sFrame.BackgroundTransparency = 1

local lab = Instance.new("TextLabel", sFrame)
lab.Size = UDim2.new(1, 0, 0, 20)
lab.Text = "Speed: 16"
lab.TextColor3 = theme.Text
lab.BackgroundTransparency = 1

local bar = Instance.new("Frame", sFrame)
bar.Size = UDim2.new(1, 0, 0, 6)
bar.Position = UDim2.new(0, 0, 0.7, 0)
bar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)

local knob = Instance.new("TextButton", bar)
knob.Size = UDim2.new(0, 20, 0, 20)
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

-- 📷 CAMERA LOCATOR
local camBtn = Instance.new("TextButton", mainFrame)
camBtn.Size = UDim2.new(0, 180, 0, 45)
camBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
camBtn.Text = "Locate Camera"
camBtn.TextColor3 = theme.Text
camBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", camBtn)

camBtn.Activated:Connect(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name:lower():find("camera") and v:IsA("Model") then 
            applyHighlight(v, Color3.fromRGB(0, 255, 255), "CamHighlighter")
        end
    end
end)

-- 🖱️ DRAG & TOGGLE LOGIC
toggleBtn.Activated:Connect(function() mainFrame.Visible = not mainFrame.Visible end)

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
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragToggle = false end end)
