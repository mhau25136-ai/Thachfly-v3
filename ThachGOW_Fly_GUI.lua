-- ThachGOW Fly GUI (LocalScript)
-- Paste this LocalScript into StarterPlayerScripts or StarterGui (as LocalScript inside a ScreenGui)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")

-- Settings
local speed = 50 -- initial speed
local flyEnabled = false
local upDownSpeed = 30

-- Create ScreenGui and layout (looks similar to your image)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ThachGOW_FlyGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 90)
mainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = screenGui

local function makeButton(name, text, pos, size, bgColor)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Text = text
    btn.Size = size
    btn.Position = pos
    btn.Font = Enum.Font.ArialBold
    btn.TextSize = 20
    btn.BackgroundColor3 = bgColor
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Parent = mainFrame
    return btn
end

-- Row 1
local btnX = makeButton("X", "X", UDim2.new(0,0,0,0), UDim2.new(0,60,0,40), Color3.fromRGB(220,50,50))
local btnMinus = makeButton("Minus1", "-", UDim2.new(0,60,0,0), UDim2.new(0,60,0,40), Color3.fromRGB(200,160,230))
local title = makeButton("Title", "ThachGOW", UDim2.new(0,120,0,0), UDim2.new(0,200,0,40), Color3.fromRGB(255,120,200))
title.TextSize = 22

-- Row 2
local btnUp = makeButton("UP", "UP", UDim2.new(0,0,0,45), UDim2.new(0,120,0,40), Color3.fromRGB(120,240,180))
local btnPlus = makeButton("Plus", "+", UDim2.new(0,120,0,45), UDim2.new(0,60,0,40), Color3.fromRGB(120,240,180))
local labelMode = makeButton("ModeLabel", "Fly GUI V3", UDim2.new(0,180,0,45), UDim2.new(0,140,0,40), Color3.fromRGB(255,150,220))
labelMode.Text = "ThachGOW" -- override to requested text
labelMode.TextSize = 18

-- Row 3
local btnDown = makeButton("DOWN", "DOWN", UDim2.new(0,0,0,90), UDim2.new(0,120,0,40), Color3.fromRGB(200,240,150))
local btnMinus2 = makeButton("Minus2", "-", UDim2.new(0,120,0,90), UDim2.new(0,60,0,40), Color3.fromRGB(150,220,250))
local btnOne = makeButton("One", "1", UDim2.new(0,180,0,90), UDim2.new(0,60,0,40), Color3.fromRGB(230,100,50))
local btnFly = makeButton("FlyToggle", "fly", UDim2.new(0,240,0,90), UDim2.new(0,140,0,40), Color3.fromRGB(250,240,150))

-- Display speed on btnOne
local function updateSpeedDisplay()
    btnOne.Text = tostring(math.floor(speed))
end
updateSpeedDisplay()

-- Fly implementation using BodyVelocity and BodyGyro
local bv, bg
local moveVector = Vector3.new(0,0,0)

local function enableFly()
    if flyEnabled then return end
    flyEnabled = true
    humanoid.PlatformStand = false -- keep animations okay
    bv = Instance.new("BodyVelocity")
    bv.Name = "ThachGOW_BV"
    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    bv.Velocity = Vector3.new(0,0,0)
    bv.P = 1250
    bv.Parent = hrp

    bg = Instance.new("BodyGyro")
    bg.Name = "ThachGOW_BG"
    bg.MaxTorque = Vector3.new(4e5,4e5,4e5)
    bg.CFrame = hrp.CFrame
    bg.P = 3000
    bg.Parent = hrp

    RunService:BindToRenderStep("ThachGOWFly", Enum.RenderPriority.Character.Value, function(dt)
        if not flyEnabled then return end
        local cam = workspace.CurrentCamera
        local camCFrame = cam.CFrame
        local forward = Vector3.new(camCFrame.LookVector.X, 0, camCFrame.LookVector.Z).Unit
        if forward ~= forward then forward = Vector3.new(0,0,0) end
        local right = Vector3.new(camCFrame.RightVector.X, 0, camCFrame.RightVector.Z).Unit
        if right ~= right then right = Vector3.new(0,0,0) end
        local horizontal = (forward * moveVector.Z + right * moveVector.X) * speed
        local vertical = Vector3.new(0, moveVector.Y * upDownSpeed, 0)
        local finalVel = horizontal + vertical
        bv.Velocity = finalVel
        bg.CFrame = workspace.CurrentCamera.CFrame
    end)
end

local function disableFly()
    if not flyEnabled then return end
    flyEnabled = false
    RunService:UnbindFromRenderStep("ThachGOWFly")
    if bv and bv.Parent then bv:Destroy() end
    if bg and bg.Parent then bg:Destroy() end
end

-- Button connections
btnFly.MouseButton1Click:Connect(function()
    if flyEnabled then
        disableFly()
        btnFly.Text = "fly"
    else
        enableFly()
        btnFly.Text = "flying"
    end
end)

btnPlus.MouseButton1Click:Connect(function()
    speed = speed + 10
    updateSpeedDisplay()
end)
btnMinus.MouseButton1Click:Connect(function()
    speed = math.max(5, speed - 10)
    updateSpeedDisplay()
end)
btnMinus2.MouseButton1Click:Connect(function()
    upDownSpeed = math.max(5, upDownSpeed - 5)
end)
btnUp.MouseButton1Click:Connect(function()
    upDownSpeed = upDownSpeed + 5
end)

-- Basic input handling for movement
local keys = {W=false, A=false, S=false, D=false, Space=false, Shift=false}

local function updateMoveVector()
    local x = 0
    local y = 0
    local z = 0
    if keys.W then z = z - 1 end
    if keys.S then z = z + 1 end
    if keys.A then x = x - 1 end
    if keys.D then x = x + 1 end
    if keys.Space then y = 1 end
    if keys.LeftShift then y = -1 end
    moveVector = Vector3.new(x, y, z)
    if moveVector.Magnitude > 1 then
        moveVector = moveVector.Unit
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then keys.W = true
    elseif input.KeyCode == Enum.KeyCode.S then keys.S = true
    elseif input.KeyCode == Enum.KeyCode.A then keys.A = true
    elseif input.KeyCode == Enum.KeyCode.D then keys.D = true
    elseif input.KeyCode == Enum.KeyCode.Space then keys.Space = true
    elseif input.KeyCode == Enum.KeyCode.LeftShift then keys.LeftShift = true
    end
    updateMoveVector()
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.W then keys.W = false
    elseif input.KeyCode == Enum.KeyCode.S then keys.S = false
    elseif input.KeyCode == Enum.KeyCode.A then keys.A = false
    elseif input.KeyCode == Enum.KeyCode.D then keys.D = false
    elseif input.KeyCode == Enum.KeyCode.Space then keys.Space = false
    elseif input.KeyCode == Enum.KeyCode.LeftShift then keys.LeftShift = false
    end
    updateMoveVector()
end)

-- Cleanup on character respawn
player.CharacterAdded:Connect(function(c)
    char = c
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    disableFly()
end)

title.MouseEnter:Connect(function()
    title.Text = "ThachGOW - Fly GUI (WASD + Space/Shift)"
end)
title.MouseLeave:Connect(function()
    title.Text = "ThachGOW"
end)
