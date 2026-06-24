local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- // STATE MANAGEMENT // --
local TracerSettings = {
    Enabled = true,
    Length = 120,
    Thickness = 0.15 -- Much tighter, thinner profile lines
}

-- // ULTRA-LIGHT NEON RGB THEME // --
local Colors = {
    Color3.fromRGB(255, 100, 100),
    Color3.fromRGB(255, 180, 50),
    Color3.fromRGB(255, 255, 120),
    Color3.fromRGB(120, 255, 120),
    Color3.fromRGB(120, 200, 255),
    Color3.fromRGB(180, 120, 255),
    Color3.fromRGB(255, 150, 255)
}

local VisualFolder = Workspace:FindFirstChild("ArjansTracers") or Instance.new("Folder", Workspace)
VisualFolder.Name = "ArjansTracers"
local ActiveBeams = {}

-- Clean up old interface installations
if CoreGui:FindFirstChild("ArjansHubV9") then
    CoreGui.ArjansHubV9:Destroy()
end

-- // INTERFACE LAYOUT // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArjansHubV9"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Main Control Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 150)
Frame.Position = UDim2.new(0.05, 0, 0.35, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 22, 27)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Visible = true
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Frame

-- Open / Close Toggle Button
local OpenCloseBtn = Instance.new("TextButton")
OpenCloseBtn.Size = UDim2.new(0, 90, 0, 30)
OpenCloseBtn.Position = UDim2.new(0, 10, 0, 10)
OpenCloseBtn.BackgroundColor3 = Color3.fromRGB(30, 33, 40)
OpenCloseBtn.Text = "Close Hub"
OpenCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenCloseBtn.Font = Enum.Font.SourceSansBold
OpenCloseBtn.TextSize = 13
OpenCloseBtn.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 6)
MenuCorner.Parent = OpenCloseBtn

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Arjan's Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 15
Title.Parent = Frame

-- Functional Toggle Button
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0, 210, 0, 35)
Toggle.Position = UDim2.new(0, 15, 0, 40)
Toggle.BackgroundColor3 = Color3.fromRGB(0, 125, 255)
Toggle.Text = "Show Trajectories: ON"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Font = Enum.Font.SourceSansSemibold
Toggle.TextSize = 14
Toggle.Parent = Frame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = Toggle

-- Value Adjustment Panel
local ValueDisplay = Instance.new("TextLabel")
ValueDisplay.Size = UDim2.new(0, 210, 0, 20)
ValueDisplay.Position = UDim2.new(0, 15, 0, 85)
ValueDisplay.BackgroundTransparency = 1
ValueDisplay.Text = "Distance: 120 studs"
ValueDisplay.TextColor3 = Color3.fromRGB(200, 200, 200)
ValueDisplay.Font = Enum.Font.SourceSans
ValueDisplay.TextSize = 13
ValueDisplay.Parent = Frame

-- CUSTOM MOBILE DRAGGABLE SLIDER TRACK
local SliderTrack = Instance.new("Frame")
SliderTrack.Size = UDim2.new(0, 210, 0, 8)
SliderTrack.Position = UDim2.new(0, 15, 0, 115)
SliderTrack.BackgroundColor3 = Color3.fromRGB(45, 48, 55)
SliderTrack.BorderSizePixel = 0
SliderTrack.Parent = Frame

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(0, 4)
TrackCorner.Parent = SliderTrack

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.35, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 125, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderTrack

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 4)
FillCorner.Parent = SliderFill

local SliderKnob = Instance.new("TextButton")
SliderKnob.Size = UDim2.new(0, 16, 0, 16)
SliderKnob.Position = UDim2.new(0.35, -8, 0.5, -8)
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.Text = ""
SliderKnob.Parent = SliderTrack

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = SliderKnob

-- // MOBILE SLIDER DRAG LOGIC // --
local IsDraggingSlider = false

local function UpdateSliderPosition(input)
    local trackWidth = SliderTrack.AbsoluteSize.X
    local relativeX = input.Position.X - SliderTrack.AbsolutePosition.X
    local percentage = math.clamp(relativeX / trackWidth, 0, 1)
    
    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    SliderKnob.Position = UDim2.new(percentage, -8, 0.5, -8)
    
    local calculatedLength = math.floor(20 + (percentage * 280))
    TracerSettings.Length = calculatedLength
    ValueDisplay.Text = "Distance: " .. tostring(calculatedLength) .. " studs"
end

SliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsDraggingSlider = true
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if IsDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        UpdateSliderPosition(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsDraggingSlider = false
    end
end)

-- // UI BUTTON TOGGLES // --
OpenCloseBtn.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
    if Frame.Visible then
        OpenCloseBtn.Text = "Close Hub"
        OpenCloseBtn.BackgroundColor3 = Color3.fromRGB(30, 33, 40)
    else
        OpenCloseBtn.Text = "Open Hub"
        OpenCloseBtn.BackgroundColor3 = Color3.fromRGB(0, 125, 255)
    end
end)

Toggle.MouseButton1Click:Connect(function()
    TracerSettings.Enabled = not TracerSettings.Enabled
    if TracerSettings.Enabled then
        Toggle.BackgroundColor3 = Color3.fromRGB(0, 125, 255)
        Toggle.Text = "Show Trajectories: ON"
    else
        Toggle.BackgroundColor3 = Color3.fromRGB(60, 65, 75)
        Toggle.Text = "Show Trajectories: OFF"
        VisualFolder:ClearAllChildren()
        table.clear(ActiveBeams)
    end
end)

-- // VISUAL RENDERING ENGINE // --
local function buildRainbowSequence()
    local keypoints = {}
    for i, color in ipairs(Colors) do
        table.insert(keypoints, ColorSequenceKeypoint.new((i - 1) / (#Colors - 1), color))
    end
    return ColorSequence.new(keypoints)
end

local function cleanModelTracer(model)
    if ActiveBeams[model] then
        pcall(function() ActiveBeams[model].Beam:Destroy() end)
        pcall(function() ActiveBeams[model].A0:Destroy() end)
        pcall(function() ActiveBeams[model].A1:Destroy() end)
        ActiveBeams[model] = nil
    end
end

local function applyVisualTracer(model, head)
    if ActiveBeams[model] then return end

    local a0 = Instance.new("Attachment")
    local a1 = Instance.new("Attachment")
    local beam = Instance.new("Beam")

    a0.Parent = head
    a1.Parent = Workspace.Terrain

    beam.Attachment0 = a0
    beam.Attachment1 = a1
    beam.FaceCamera = true
    beam.Color = buildRainbowSequence()
    beam.Transparency = NumberSequence.new(0.0)
    beam.Parent = VisualFolder

    ActiveBeams[model] = {Beam = beam, A0 = a0, A1 = a1, Head = head}
end

-- // ENEMY FILTER DETERMINATION // --
local function isEnemy(model)
    if model.Name == LocalPlayer.Name then return false end
    
    local targetPlayer = Players:FindFirstChild(model.Name)
    local myChar = LocalPlayer.Character or Workspace:FindFirstChild(LocalPlayer.Name)
    
    if targetPlayer and myChar and myChar:FindFirstChild("HumanoidRootPart") and model:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Team and targetPlayer.Team then
            return LocalPlayer.Team ~= targetPlayer.Team
        end
        if LocalPlayer.TeamColor ~= BrickColor.new("White") and LocalPlayer.TeamColor == targetPlayer.TeamColor then
            return false
        end

        local distance = (model.HumanoidRootPart.Position - myChar.HumanoidRootPart.Position).Magnitude
        if distance < 35 then
            return false
        end
    end
    return true
end

-- // BALANCED SCANNER SCHEDULE // --
task.spawn(function()
    while task.wait(0.3) do
        if TracerSettings.Enabled then
            local presentModels = {}
            
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                    local head = obj:FindFirstChild("Head") or obj:FindFirstChild("UpperTorso")
                    
                    if head and isEnemy(obj) then
                        presentModels[obj] = true
                        if not ActiveBeams[obj] then
                            applyVisualTracer(obj, head)
                        end
                    end
                end
            end
            
            for model, _ in pairs(ActiveBeams) do
                if not presentModels[model] then
                    cleanModelTracer(model)
                end
            end
        end
    end
end)

-- // FRAME PIPELINE LOCK ENGINE // --
RunService.RenderStepped:Connect(function()
    if not TracerSettings.Enabled then return end

    for model, data in pairs(ActiveBeams) do
        if data.Head and data.Head.Parent then
            -- Tighter visual locks applied over updates here
            data.Beam.Width0 = TracerSettings.Thickness
            data.Beam.Width1 = TracerSettings.Thickness

            local rawLook = data.Head.CFrame.LookVector
            local flatDirection = Vector3.new(rawLook.X, 0, rawLook.Z).Unit

            data.A0.WorldPosition = data.Head.Position
            data.A1.WorldPosition = data.Head.Position + (flatDirection * TracerSettings.Length)
            data.Beam.Enabled = true
        else
            cleanModelTracer(model)
        end
    end
end)
