--[[
    Created by Light
    ⚡ SPEED BOOST SCRIPT
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local pgui = player:WaitForChild("PlayerGui")

if pgui:FindFirstChild("SpeedBoostGui") then
    pgui.SpeedBoostGui:Destroy()
end

local targetSpeed = 16
local boostEnabled = false

local screenGui = Instance.new("ScreenGui", pgui)
screenGui.Name = "SpeedBoostGui"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 240, 0, 160)
mainFrame.Position = UDim2.new(0.5, -120, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.SourceSansBold

closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = Color3.fromRGB(240, 60, 60) end)
closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = Color3.fromRGB(150, 150, 160) end)

closeBtn.Activated:Connect(function()
    boostEnabled = false
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16 end
    screenGui:Destroy()
end)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, -40, 0, 35)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ SPEED BY LIGHT"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.SourceSansBold
title.TextXAlignment = Enum.TextXAlignment.Left

local speedInput = Instance.new("TextBox", mainFrame)
speedInput.Size = UDim2.new(1, -20, 0, 35)
speedInput.Position = UDim2.new(0, 10, 0, 45)
speedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
speedInput.Text = "50"
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Font = Enum.Font.SourceSansBold
speedInput.TextSize = 16
Instance.new("UICorner", speedInput).CornerRadius = UDim.new(0, 5)

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, -20, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 95)
toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
toggleBtn.Text = "ВКЛЮЧИТЬ БУСТ"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 14
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 5)

local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = mainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

toggleBtn.Activated:Connect(function()
    boostEnabled = not boostEnabled
    if boostEnabled then
        local num = tonumber(speedInput.Text)
        targetSpeed = num or 50
        speedInput.Text = tostring(targetSpeed)
        toggleBtn.Text = "ВЫКЛЮЧИТЬ БУСТ"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        toggleBtn.Text = "ВКЛЮЧИТЬ БУСТ"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end)

RunService.Heartbeat:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and boostEnabled then
        if hum.WalkSpeed ~= targetSpeed then
            hum.WalkSpeed = targetSpeed
        end
    end
end)
