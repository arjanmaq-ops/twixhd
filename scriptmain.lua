local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- 🔒 SETTINGS
local espActive, divebellEspActive = false, false
local walkSpeedActive = false
local fullbrightActive = false
local currentSpeed = 16

-- Store original settings to restore them perfectly
local origSettings = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient
}

-- 🎯 HIGHLIGHTER
local function applyHighlight(model, color, name)
    if not model:IsA("Model") then return end
    local h = model:FindFirstChild(name) or Instance.new("Highlight")
    h.Name = name
    h.Parent = model
    h.Enabled = true
    h.OutlineColor = color
    h.OutlineTransparency = 0 
    h.FillTransparency = 1 
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

-- 🌀 MAIN LOOP
RunService.Heartbeat:Connect(function()
    local char = player.Character
    
    -- Fullbright Logic (Vibrant Colors Version)
    if fullbrightActive then
        Lighting.Ambient = Color3.new(1, 1, 1) 
        Lighting.Brightness = 1
        Lighting.FogEnd = 1e6
        Lighting.GlobalShadows = false
    end

    -- Visuals (ESP)
    if espActive then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
                applyHighlight(obj, Color3.fromRGB(255, 255, 0), "ArjanHighlighter")
            end
        end
    else
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "ArjanHighlighter" then v:Destroy() end
        end
    end

    if divebellEspActive then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name == "SurfaceBell" or obj.Name == "SubmergeBell") then
                applyHighlight(obj, Color3.fromRGB(0, 255, 0), "DivebellESP")
            end
        end
    else
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "DivebellESP" then v:Destroy() end
        end
    end

    -- Speed
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = walkSpeedActive and currentSpeed or 16 end
end)

-- 📱 UI CONSTRUCTION
local screenGui = Instance.new("ScreenGui", CoreGui)
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size, toggleBtn.Position = UDim2.new(0, 55, 0, 55), UDim2.new(0.05, 0, 0.2, 0)
toggleBtn.BackgroundColor3, toggleBtn.Text = Color3.fromRGB(114, 185, 245), "≡"
toggleBtn.TextColor3, toggleBtn.TextSize = Color3.new(1,1,1), 35
Instance.new("UICorner", toggleBtn)

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size, mainFrame.Position = UDim2.new(0, 260, 0, 360), UDim2.new(0.5, -130, 0.5, -180)
mainFrame.BackgroundColor3, mainFrame.Visible = Color3.fromRGB(20, 20, 23), false
Instance.new("UICorner", mainFrame)

local tabHolder = Instance.new("Frame", mainFrame)
tabHolder.Size, tabHolder.BackgroundTransparency = UDim2.new(1, 0, 0, 35), 1
Instance.new("UIListLayout", tabHolder).FillDirection = Enum.FillDirection.Horizontal

local container = Instance.new("Frame", mainFrame)
container.Size, container.Position = UDim2.new(1, -30, 1, -60), UDim2.new(0, 15, 0, 50)
container.BackgroundTransparency = 1

local function createTab(name)
    local btn = Instance.new("TextButton", tabHolder)
    btn.Size, btn.BackgroundTransparency, btn.Text = UDim2.new(0.5, 0, 1, 0), 1, name
    btn.TextColor3, btn.Font, btn.TextSize = Color3.new(0.5, 0.5, 0.5), Enum.Font.SourceSansBold, 16
    local section = Instance.new("Frame", container)
    section.Size, section.BackgroundTransparency, section.Visible = UDim2.new(1, 0, 1, 0), 1, false
    Instance.new("UIListLayout", section).Padding = UDim.new(0, 8)
    btn.Activated:Connect(function()
        for _, v in ipairs(container:GetChildren()) do if v:IsA("Frame") then v.Visible = false end end
        for _, t in ipairs(tabHolder:GetChildren()) do if t:IsA("TextButton") then t.TextColor3 = Color3.new(0.5, 0.5, 0.5) end end
        section.Visible, btn.TextColor3 = true, Color3.fromRGB(114, 185, 245)
    end)
    return section, btn
end

local function createToggle(parent, text, callback)
    local row = Instance.new("Frame", parent)
    row.Size, row.BackgroundColor3 = UDim2.new(1, 0, 0, 40), Color3.fromRGB(30, 30, 35)
    Instance.new("UICorner", row)
    local l = Instance.new("TextLabel", row)
    l.Size, l.Position, l.BackgroundTransparency, l.Text = UDim2.new(0.6, 0, 1, 0), UDim2.new(0, 12, 0, 0), 1, text
    l.TextColor3, l.TextXAlignment = Color3.new(1,1,1), Enum.TextXAlignment.Left
    local dot = Instance.new("Frame", row)
    dot.Size, dot.Position, dot.BackgroundColor3 = UDim2.new(0, 20, 0, 20), UDim2.new(1, -32, 0.5, -10), Color3.fromRGB(60, 60, 65)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local state = false
    local b = Instance.new("TextButton", row)
    b.Size, b.BackgroundTransparency, b.Text = UDim2.new(1,0,1,0), 1, ""
    b.Activated:Connect(function()
        state = not state
        dot.BackgroundColor3 = state and Color3.fromRGB(114, 185, 245) or Color3.fromRGB(60, 60, 65)
        callback(state)
    end)
end

-- 🏃 MOVE TAB
local moveTab, moveBtn = createTab("Move")

local tpBtn = Instance.new("TextButton", moveTab)
tpBtn.Size, tpBtn.BackgroundColor3 = UDim2.new(1, 0, 0, 40), Color3.fromRGB(30, 30, 35)
tpBtn.Text, tpBtn.TextColor3 = "TP to SubmergeBell", Color3.new(1,1,1)
Instance.new("UICorner", tpBtn)
tpBtn.Activated:Connect(function()
    local target = workspace:FindFirstChild("SubmergeBell", true)
    if target and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = target:GetModelCFrame()
    end
end)

createToggle(moveTab, "Enable Speed", function(s) walkSpeedActive = s end)

local sFrame = Instance.new("Frame", moveTab)
sFrame.Size, sFrame.BackgroundTransparency = UDim2.new(1, 0, 0, 60), 1 -- Increased height for padding
local lab = Instance.new("TextLabel", sFrame)
lab.Size, lab.BackgroundTransparency, lab.Text, lab.TextColor3 = UDim2.new(1, 0, 0, 20), 1, "Speed: 16", Color3.new(0.7,0.7,0.7)

local bar = Instance.new("Frame", sFrame)
bar.Size, bar.Position, bar.BackgroundColor3 = UDim2.new(1, -20, 0, 8), UDim2.new(0, 10, 0.7, 0), Color3.fromRGB(45, 45, 50)
Instance.new("UICorner", bar)

local knob = Instance.new("TextButton", bar)
knob.Size, knob.AnchorPoint, knob.BackgroundColor3 = UDim2.new(0, 35, 0, 35), Vector2.new(0.5, 0.5), Color3.fromRGB(114, 185, 245)
knob.Text = ""
knob.Active = true -- Important for mobile touch registration
Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

knob.InputChanged:Connect(function(i)
    if (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        knob.Position = UDim2.new(p, 0, 0.5, 0)
        currentSpeed = math.floor(16 + (p * 184))
        lab.Text = "Speed: " .. currentSpeed
    end
end)

-- 👁️ VISUAL TAB
local visualTab, visualBtn = createTab("Visual")
createToggle(visualTab, "Universal ESP", function(s) espActive = s end)
createToggle(visualTab, "Divebell ESP", function(s) divebellEspActive = s end)

createToggle(visualTab, "Fullbright", function(s) 
    fullbrightActive = s 
    if not s then
        Lighting.Ambient = origSettings.Ambient
        Lighting.Brightness = origSettings.Brightness
        Lighting.ClockTime = origSettings.ClockTime
        Lighting.FogEnd = origSettings.FogEnd
        Lighting.GlobalShadows = origSettings.GlobalShadows
    end
end)

local camBtn = Instance.new("TextButton", visualTab)
camBtn.Size, camBtn.BackgroundColor3 = UDim2.new(1, 0, 0, 40), Color3.fromRGB(30, 30, 35)
camBtn.Text, camBtn.TextColor3 = "Locate All Cameras", Color3.new(1,1,1)
Instance.new("UICorner", camBtn)
camBtn.Activated:Connect(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name:lower():find("camera") and v:IsA("Model") then 
            applyHighlight(v, Color3.fromRGB(0, 255, 255), "CamHighlighter")
        end
    end
end)

-- Init
moveBtn.TextColor3 = Color3.fromRGB(114, 185, 245)
moveTab.Visible = true
toggleBtn.Activated:Connect(function() mainFrame.Visible = not mainFrame.Visible end)
