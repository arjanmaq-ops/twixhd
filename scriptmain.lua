local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- 🔒 INITIAL SETTINGS (Set to False/Default as requested)
local espEnabled = false --
local currentSpeed = 16  --
local MIN_SPEED, MAX_SPEED = 16, 200

-- 🎯 SELECTION BOX ESP (Highly Stable)
local function createESP(model, color, name)
    if not model or model:FindFirstChild(name) then return end
    
    local box = Instance.new("SelectionBox")
    box.Name = name
    box.Adornee = model
    box.Color3 = color
    box.LineThickness = 0.05
    box.SurfaceTransparency = 1
    box.AlwaysOnTop = true
    box.Parent = model
end

-- 🟡 MONITORING LOOP
RunService.Heartbeat:Connect(function()
    -- Cleanup if ESP is turned off
    if not espEnabled then 
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "ArjanESP" or v.Name == "CamESP" then v:Destroy() end
        end
        return 
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            if not Players:GetPlayerFromCharacter(obj) or obj ~= player.Character then
                createESP(obj, Color3.fromRGB(255, 255, 0), "ArjanESP")
            end
        end
    end
end)

-- 📱 UI THEME
local theme = {
    Bg = Color3.fromRGB(20, 20, 25),
    Accent = Color3.fromRGB(59, 162, 235), 
    Text = Color3.fromRGB(255, 255, 255),
    Dark = Color3.fromRGB(35, 35, 40)
}

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name, screenGui.ResetOnSpawn = "ArjanHubUI", false

-- 🔵 DRAGGABLE TOGGLE BUTTON
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0.8, 0, 0.2, 0)
toggleBtn.BackgroundColor3 = theme.Accent
toggleBtn.Text = "≡"
toggleBtn.TextColor3 = theme.Text
toggleBtn.TextSize = 40
toggleBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

-- 📦 MAIN MENU
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 200, 0, 260)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -130)
mainFrame.BackgroundColor3 = theme.Bg
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "Arjan’s Hub"
title.TextColor3 = theme.Text
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local content = Instance.new("Frame", mainFrame)
content.Size = UDim2.new(1, 0, 1, -50)
content.Position = UDim2.new(0, 0, 0, 50)
content.BackgroundTransparency = 1
local list = Instance.new("UIListLayout", content)
list.Padding, list.HorizontalAlignment = UDim.new(0, 12), Enum.HorizontalAlignment.Center

-- 🔘 COMPONENTS
local function addToggle(text, callback)
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(0, 170, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(60, 30, 30) -- Starts Red (OFF)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = theme.Text
    btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn)
    
    local active = false
    btn.Activated:Connect(function()
        active = not active
        btn.Text = text .. (active and ": ON" or ": OFF")
        btn.BackgroundColor3 = active and theme.Dark or Color3.fromRGB(60, 30, 30)
        callback(active)
    end)
end

local function addSlider()
    local sFrame = Instance.new("Frame", content)
    sFrame.Size = UDim2.new(0, 170, 0, 60)
    sFrame.BackgroundTransparency = 1
    
    local lab = Instance.new("TextLabel", sFrame)
    lab.Size = UDim2.new(1, 0, 0, 25)
    lab.Text = "Speed: 16"
    lab.TextColor3 = theme.Text
    lab.BackgroundTransparency = 1
    
    local bar = Instance.new("Frame", sFrame)
    bar.Size = UDim2.new(1, 0, 0, 4)
    bar.Position = UDim2.new(0, 0, 0.8, 0)
    bar.BackgroundColor3 = theme.Dark
    
    local knob = Instance.new("TextButton", bar)
    knob.Size = UDim2.new(0, 18, 0, 18)
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

addToggle("ESP", function(val) espEnabled = val end)
addSlider()

local camBtn = Instance.new("TextButton", content)
camBtn.Size = UDim2.new(0, 170, 0, 40)
camBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
camBtn.Text = "Find Camera"
camBtn.TextColor3 = theme.Text
camBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", camBtn)
camBtn.Activated:Connect(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name:find("Camera") then 
            createESP(v, Color3.fromRGB(0, 255, 255), "CamESP") 
        end
    end
end)

-- 🖱️ INTERACTION LOGIC
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

task.spawn(function()
    while true do
        local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if h and h.WalkSpeed ~= currentSpeed then 
            h.WalkSpeed = currentSpeed 
        end
        task.wait(0.2)
    end
end)
