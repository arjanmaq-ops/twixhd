local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- 🔒 SETTINGS (OFF BY DEFAULT)
local espActive = false
local walkSpeedActive = false
local currentSpeed = 16

-- 🎯 HIGHLIGHTER LOGIC
local function applyHighlight(model, color, name)
    if not model:IsA("Model") then return end
    local h = model:FindFirstChild(name) or Instance.new("Highlight")
    h.Name = name
    h.Parent = model
    h.Enabled = espActive
    h.FillTransparency = 1 
    h.OutlineColor = color
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

RunService.RenderStepped:Connect(function()
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
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = walkSpeedActive and currentSpeed or 16
    end
end)

-- 📱 UI CONSTRUCTION (Compact Style)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ArjanHubUI"
pcall(function() screenGui.Parent = CoreGui end)

-- Light Blue Menu Toggle (Blue Square with ≡)
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size = UDim2.new(0, 55, 0, 55)
toggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(114, 185, 245)
toggleBtn.Text = "≡"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextSize = 35
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 12)

-- Main Frame (Dark Minimalist)
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 260, 0, 300)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)

-- Tab Navigation
local tabHolder = Instance.new("Frame", mainFrame)
tabHolder.Size = UDim2.new(1, 0, 0, 35)
tabHolder.Position = UDim2.new(0, 0, 0, 10)
tabHolder.BackgroundTransparency = 1
local tabLayout = Instance.new("UIListLayout", tabHolder)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.Padding = UDim.new(0, 15)

local container = Instance.new("Frame", mainFrame)
container.Size = UDim2.new(1, -30, 1, -60)
container.Position = UDim2.new(0, 15, 0, 50)
container.BackgroundTransparency = 1

local function createTab(name)
    local btn = Instance.new("TextButton", tabHolder)
    btn.Size = UDim2.new(0, 80, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Color3.new(0.5, 0.5, 0.5)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16

    local section = Instance.new("Frame", container)
    section.Size = UDim2.new(1, 0, 1, 0)
    section.BackgroundTransparency = 1
    section.Visible = false
    Instance.new("UIListLayout", section).Padding = UDim.new(0, 10)

    btn.Activated:Connect(function()
        for _, v in ipairs(container:GetChildren()) do if v:IsA("Frame") then v.Visible = false end end
        for _, t in ipairs(tabHolder:GetChildren()) do if t:IsA("TextButton") then t.TextColor3 = Color3.new(0.5, 0.5, 0.5) end end
        section.Visible = true
        btn.TextColor3 = Color3.fromRGB(114, 185, 245)
    end)
    return section, btn
end

-- 🔘 TOGGLE BUILDER
local function createToggle(parent, text, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 45)
    row.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Instance.new("UICorner", row)
    
    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16

    local dot = Instance.new("Frame", row)
    dot.Size = UDim2.new(0, 22, 0, 22)
    dot.Position = UDim2.new(1, -35, 0.5, -11)
    dot.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    local state = false
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Activated:Connect(function()
        state = not state
        dot.BackgroundColor3 = state and Color3.fromRGB(114, 185, 245) or Color3.fromRGB(60, 60, 65)
        callback(state)
    end)
end

-- 🏃 MOVEMENT TAB
local moveTab, moveBtn = createTab("Move")
createToggle(moveTab, "Enable Speed", function(s) walkSpeedActive = s end)

local sFrame = Instance.new("Frame", moveTab)
sFrame.Size = UDim2.new(1, 0, 0, 55)
sFrame.BackgroundTransparency = 1
local lab = Instance.new("TextLabel", sFrame)
lab.Size = UDim2.new(1, 0, 0, 20)
lab.Text = "Speed: 16"
lab.TextColor3 = Color3.new(0.7, 0.7, 0.7)
lab.BackgroundTransparency = 1
local bar = Instance.new("Frame", sFrame)
bar.Size = UDim2.new(1, -10, 0, 5)
bar.Position = UDim2.new(0, 5, 0.7, 0)
bar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
local knob = Instance.new("TextButton", bar)
knob.Size = UDim2.new(0, 18, 0, 18)
knob.AnchorPoint = Vector2.new(0.5, 0.5)
knob.Position = UDim2.new(0, 0, 0.5, 0)
knob.BackgroundColor3 = Color3.fromRGB(114, 185, 245)
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

local camBtn = Instance.new("TextButton", visualTab)
camBtn.Size = UDim2.new(1, 0, 0, 45)
camBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
camBtn.Text = "Locate Cameras"
camBtn.TextColor3 = Color3.new(1,1,1)
camBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", camBtn)
camBtn.Activated:Connect(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name:lower():find("camera") and v:IsA("Model") then 
            applyHighlight(v, Color3.fromRGB(0, 255, 255), "CamHighlighter")
        end
    end
end)

-- Initialize
moveBtn.TextColor3 = Color3.fromRGB(114, 185, 245)
moveTab.Visible = true

-- Drag & Toggle Logic
toggleBtn.Activated:Connect(function() mainFrame.Visible = not mainFrame.Visible end)
local dDragging, dStart, sPos
toggleBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dDragging = true dStart = i.Position sPos = toggleBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dStart
        toggleBtn.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function() dDragging = false end)
