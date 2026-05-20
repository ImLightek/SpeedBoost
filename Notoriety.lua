local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Notoriety Suite | Written by Light", "DarkTheme")

local MainTab = Window:NewTab("Movement")
local Section = MainTab:NewSection("Bypass Modules")

local VisualsTab = Window:NewTab("Visuals")
local VisualsSection = VisualsTab:NewSection("ESP")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local flyEnabled = false
local noclipEnabled = false
local speedEnabled = false
local guardEspEnabled = false
local civilianEspEnabled = false
local itemEspEnabled = false

local flySpeed = 25 
local walkSpeedValue = 25 

local GuardCache = {}
local CivilianCache = {}
local CardCache = {}

local function createEsp(model, color, labelText, cacheTable)
    if not model or not model.Parent then return end
    local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildOfClass("MeshPart") or model:FindFirstChildOfClass("Part")
    if not hrp or hrp:FindFirstChild("LightESP") then return end

    local bgui = Instance.new("BillboardGui")
    bgui.Name = "LightESP"
    bgui.AlwaysOnTop = true
    bgui.Size = UDim2.new(0, 120, 0, 30)
    bgui.Adornee = hrp
    bgui.Parent = hrp

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = labelText
    textLabel.TextColor3 = color
    textLabel.TextSize = 13
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextStrokeTransparency = 0
    textLabel.Parent = bgui

    local highlight = Instance.new("Highlight")
    highlight.Name = "LightHighlight"
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.2
    highlight.Adornee = model
    highlight.Parent = (model:IsA("Model") and model or hrp)

    cacheTable[model] = {Gui = bgui, High = highlight}
end

local function clearCacheTable(cacheTable)
    for model, elements in pairs(cacheTable) do
        pcall(function()
            if elements.Gui then elements.Gui:Destroy() end
            if elements.High then elements.High:Destroy() end
        end)
        cacheTable[model] = nil
    end
end

local function checkNPC(model)
    if not model:IsA("Model") or not model:FindFirstChild("Humanoid") or not model:FindFirstChild("HumanoidRootPart") then return nil, false end
    if Players:GetPlayerFromCharacter(model) then return nil, false end
    
    local name = model.Name:lower()
    local hasKeycard = false
    
    if model:FindFirstChild("Keycard") or model:FindFirstChild("Key Card") or model:FindFirstChild("MagneticCard") or model:FindFirstChild("AccessCard") then
        hasKeycard = true
    end
    
    for _, item in ipairs(model:GetChildren()) do
        if item:IsA("StringValue") and (item.Name:lower():find("card") or item.Value:lower():find("card")) then
            hasKeycard = true
            break
        end
    end
    
    if name:find("guard") or name:find("police") or name:find("swat") or name:find("agent") or model:FindFirstChild("Radio") or model:FindFirstChild("Pager") then
        return "guard", hasKeycard
    end
    
    if name:find("civilian") or name:find("manager") or name:find("witness") or name:find("hostage") or model:FindFirstChild("Panic") or (model.Humanoid.MaxHealth == 100 and not name:find("dummy")) then
        return "civilian", hasKeycard
    end
    
    return nil, false
end

local function isWorldKeycard(obj)
    if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("Model") then
        local name = obj.Name:lower()
        if name:find("keycard") or name:find("key_card") or name:find("magneticcard") or name:find("access_card") then
            return true
        end
        if obj.Parent and obj.Parent.Name:lower():find("keycard") then
            return true
        end
    end
    return false
end

local function processObject(obj)
    if not obj or not obj.Parent then return end
    
    local npcType, hasKeycard = checkNPC(obj)
    if npcType == "guard" and guardEspEnabled then
        if hasKeycard then
            createEsp(obj, Color3.fromRGB(255, 165, 0), "Guard [KEYCARD]", GuardCache)
        else
            createEsp(obj, Color3.fromRGB(255, 50, 50), "Guard", GuardCache)
        end
    elseif npcType == "civilian" and civilianEspEnabled then
        if hasKeycard then
            createEsp(obj, Color3.fromRGB(255, 215, 0), "Civilian [KEYCARD]", CivilianCache)
        else
            createEsp(obj, Color3.fromRGB(50, 255, 50), "Civilian", CivilianCache)
        end
    elseif isWorldKeycard(obj) and itemEspEnabled then
        createEsp(obj, Color3.fromRGB(160, 32, 240), "[KEYCARD]", CardCache)
    end
end

RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if flyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local camera = workspace.CurrentCamera
        local moveDirection = Vector3.new(0, 0, 0)
        
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
        
        if moveDirection.Magnitude > 0 then
            hrp.Velocity = moveDirection.Unit * flySpeed
        else
            hrp.Velocity = Vector3.new(0, math.sin(tick() * 10) * 0.2, 0)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local hrp = LocalPlayer.Character.HumanoidRootPart
        
        if hum and hum.MoveDirection.Magnitude > 0 then
            local targetVelocity = hum.MoveDirection * walkSpeedValue
            hrp.Velocity = Vector3.new(targetVelocity.X, hrp.Velocity.Y, targetVelocity.Z)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do 
        if guardEspEnabled or civilianEspEnabled or itemEspEnabled then
            for _, obj in ipairs(workspace:GetChildren()) do
                processObject(obj)
            end
            if workspace:FindFirstChild("Entities") then
                for _, obj in ipairs(workspace.Entities:GetChildren()) do
                    processObject(obj)
                end
            end
        end
    end
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        local gui = game:GetService("CoreGui"):FindFirstChild("Notoriety Suite | Written by Light") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Notoriety Suite | Written by Light")
        if gui then
            gui.Enabled = not gui.Enabled
        end
    end
end)

Section:NewToggle("Legit Fly", "Fly (W,A,S,D + Space/Shift)", function(state)
    flyEnabled = state
end)

Section:NewSlider("Fly Speed", "Max 60 recommended", 80, 15, function(s)
    flySpeed = s
end)

Section:NewToggle("Legit Speed", "Speedhack", function(state)
    speedEnabled = state
end)

Section:NewSlider("Speed Value", "Recommended: 25-45", 60, 16, function(s)
    walkSpeedValue = s
end)

Section:NewToggle("NoClip", "Wallpass", function(state)
    noclipEnabled = state
end)

VisualsSection:NewToggle("Guard ESP", "Show Guards", function(state)
    guardEspEnabled = state
    if not state then
        clearCacheTable(GuardCache)
    end
end)

VisualsSection:NewToggle("Civilian ESP", "Show Civilians", function(state)
    civilianEspEnabled = state
    if not state then
        clearCacheTable(CivilianCache)
    end
end)

VisualsSection:NewToggle("Keycards on Map", "Show World Keycards", function(state)
    itemEspEnabled = state
    if not state then
        clearCacheTable(CardCache)
    end
end)
