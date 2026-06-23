local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local inputService = game:GetService("UserInputService")

local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "ArjanUltimateFly"
screenGui.ResetOnSpawn = false

-- Mini Menu (Left)
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 120, 0, 80)
mainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainFrame.Active = true
mainFrame.Draggable = true

local invisBtn = Instance.new("TextButton", mainFrame)
invisBtn.Size = UDim2.new(1, -10, 0, 35)
invisBtn.Position = UDim2.new(0, 5, 0, 5)
invisBtn.Text = "Invis: OFF"
invisBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
invisBtn.TextColor3 = Color3.new(1, 1, 1)

local sliderBar = Instance.new("Frame", mainFrame)
sliderBar.Size = UDim2.new(1, -20, 0, 4)
sliderBar.Position = UDim2.new(0, 10, 0, 60)
sliderBar.BackgroundColor3 = Color3.new(0, 0, 0)

local handle = Instance.new("TextButton", sliderBar)
handle.Size = UDim2.new(0, 16, 0, 16)
handle.Position = UDim2.new(0, 0, 0.5, 0)
handle.AnchorPoint = Vector2.new(0.5, 0.5)
handle.Text = ""

-- UP/DOWN Buttons
local upBtn = Instance.new("TextButton", screenGui)
upBtn.Size = UDim2.new(0, 50, 0, 50)
upBtn.Position = UDim2.new(0.88, 0, 0.02, 0)
upBtn.Text = "▲"
upBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
upBtn.BackgroundTransparency = 0.4
upBtn.Font = Enum.Font.GothamBold

local downBtn = Instance.new("TextButton", screenGui)
downBtn.Size = UDim2.new(0, 50, 0, 50)
downBtn.Position = UDim2.new(0.88, 0, 0.11, 0)
downBtn.Text = "▼"
downBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
downBtn.BackgroundTransparency = 0.4
downBtn.Font = Enum.Font.GothamBold

-- --- LOGIC ---
local flySpeed = 0
local verticalForce = 0
local isInvis = false
local dragging = false

-- Speed Slider
handle.MouseButton1Down:Connect(function() dragging = true end)
inputService.InputEnded:Connect(function(input) 
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end 
end)

inputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local rel = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        handle.Position = UDim2.new(rel, 0, 0.5, 0)
        flySpeed = rel * 4.5
    end
end)

-- Fly Controls
upBtn.MouseButton1Down:Connect(function() verticalForce = 1.2 end)
upBtn.MouseButton1Up:Connect(function() verticalForce = 0 end)
downBtn.MouseButton1Down:Connect(function() verticalForce = -1.2 end)
downBtn.MouseButton1Up:Connect(function() verticalForce = 0 end)

-- Toggle Invisibility
invisBtn.MouseButton1Click:Connect(function()
    isInvis = not isInvis
    invisBtn.Text = isInvis and "Invis: ON" or "Invis: OFF"
    
    local char = player.Character
    if char and not isInvis then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.Transparency = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 0
            elseif v:IsA("Accessory") and v:FindFirstChild("Handle") then
                v.Handle.Transparency = 0
            end
        end
    end
end)

runService.Heartbeat:Connect(function()
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        
        -- Fly Movement
        if hrp and hum and (hum.MoveDirection.Magnitude > 0 or verticalForce ~= 0) then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * flySpeed) + Vector3.new(0, verticalForce, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- Safe Local Displacement Invis
        if isInvis and hrp then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    v.Transparency = 1
                elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance") then
                    if v:IsA("SurfaceAppearance") then v:Destroy() else v.Transparency = 1 end
                elseif v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
                    v:Destroy()
                elseif v:IsA("Accessory") then
                    local h = v:FindFirstChild("Handle")
                    if h then h.Transparency = 1 end
                end
            end
            
            if hum then
                hum.PlatformStand = false
            end
        end
    end
end)
