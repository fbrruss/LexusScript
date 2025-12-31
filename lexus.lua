-- секс
-- lexuscript v0.0.0
-- build: 0.0.7 (Animated Ball UI & PC Features)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local s = {
    aim = false,
    esp_wall = false,
    dash_enabled = false,
    dash_cd = false,
    click_tp = false,
    noreload = false,
    backalert = false,
    antistun = false
}

-- [ UI SETUP ]
local screen = Instance.new("ScreenGui", game.CoreGui)
screen.Name = "LexusPremium_v0"

-- Кнопка сворачивания (в углу меню)
local main = Instance.new("Frame", screen)
main.Size = UDim2.new(0, 480, 0, 450)
main.Position = UDim2.new(0.5, -240, 0.5, -225)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(60, 60, 80)
stroke.Thickness = 2

-- Шарик (Свернутое состояние)
local ball = Instance.new("ImageButton", screen)
ball.Size = UDim2.new(0, 60, 0, 60)
ball.Position = UDim2.new(0.9, 0, 0.1, 0)
ball.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
ball.Visible = false
ball.AutoButtonColor = false
Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)
local ballStroke = Instance.new("UIStroke", ball)
ballStroke.Color = Color3.fromRGB(100, 100, 255)
ballStroke.Thickness = 2

-- Анимация пульсации шарика
task.spawn(function()
    while true do
        TweenService:Create(ball, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 65, 0, 65)}):Play()
        task.wait(1)
        TweenService:Create(ball, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 55, 0, 55)}):Play()
        task.wait(1)
    end
end)

-- Логика сворачивания/разворачивания
local function toggleUI(minimize)
    if minimize then
        main:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.3, true)
        task.wait(0.3)
        main.Visible = false
        ball.Visible = true
        ball.Position = UDim2.new(0.9, -30, 0.1, 0)
    else
        ball.Visible = false
        main.Visible = true
        main:TweenSize(UDim2.new(0, 480, 0, 450), "Out", "Back", 0.4, true)
    end
end

-- Кнопка закрытия в меню
local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -40, 0, 10)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.BackgroundTransparency = 1
minBtn.TextSize = 30
minBtn.MouseButton1Click:Connect(function() toggleUI(true) end)

ball.MouseButton1Click:Connect(function() toggleUI(false) end)
ball.Draggable = true
main.Draggable = true

-- [ FEATURES ]
local container = Instance.new("ScrollingFrame", main)
container.Size = UDim2.new(1, -20, 1, -80)
container.Position = UDim2.new(0, 10, 0, 60)
container.BackgroundTransparency = 1
container.ScrollBarThickness = 0
local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 5)

local function make_toggle(name, var)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    btn.Text = "   " .. name
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)
    
    local ind = Instance.new("Frame", btn)
    ind.Size = UDim2.new(0, 12, 0, 12)
    ind.Position = UDim2.new(1, -30, 0.5, -6)
    ind.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)

    btn.MouseButton1Click:Connect(function()
        s[var] = not s[var]
        TweenService:Create(ind, TweenInfo.new(0.3), {BackgroundColor3 = s[var] and Color3.fromRGB(50, 255, 100) or Color3.fromRGB(255, 50, 50)}):Play()
    end)
end

-- ФУНКЦИЯ АИМБОТА ИЗ ПЕРВОГО СКРИПТА (ДОБАВЛЕНА)
local function get_target()
    local best = nil
    local min_dist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            -- Check visibility
            local origin = Camera.CFrame.Position
            local dest = v.Character.Head.Position
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {LocalPlayer.Character}
            params.FilterType = Enum.RaycastFilterType.Blacklist
            local ray = Workspace:Raycast(origin, (dest - origin), params)

            if ray and ray.Instance:IsDescendantOf(v.Character) then  
                local screen_pos, on_screen = Camera:WorldToViewportPoint(dest)  
                if on_screen then  
                    local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screen_pos.X, screen_pos.Y)).Magnitude  
                    if dist < min_dist then  
                        min_dist = dist  
                        best = v  
                    end  
                end  
            end  
        end  
    end  
    return best
end

-- 1. Aim + AutoShot (ИСПРАВЛЕННАЯ ВЕРСИЯ С ФУНКЦИЕЙ ИЗ ПЕРВОГО СКРИПТА)
make_toggle("Silent Aim V2 + AutoShot (RMB)", "aim")
RunService.RenderStepped:Connect(function()
    if s.aim and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = get_target()
        if t and t.Character and t.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position)
            if mouse1click then mouse1click() end -- Auto shoot
        end
    end
end)

-- 2. Wall ESP Only
make_toggle("ESP (Behind Walls Only)", "esp_wall")
RunService.Heartbeat:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local hl = p.Character:FindFirstChild("LexusESP") or Instance.new("Highlight", p.Character)
            hl.Name = "LexusESP"
            local ray = Workspace:Raycast(Camera.CFrame.Position, (p.Character.Head.Position - Camera.CFrame.Position).Unit * 1000, RaycastParams.new())
            local is_hidden = not (ray and ray.Instance:IsDescendantOf(p.Character))
            hl.Enabled = s.esp_wall and is_hidden
        end
    end
end)

-- 3. Dash (Y) - Physics
make_toggle("Physics Dash (Key: Y)", "dash_enabled")
UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.Y and s.dash_enabled and not s.dash_cd then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            s.dash_cd = true
            local bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(1e5, 0, 1e5)
            bv.Velocity = hrp.CFrame.LookVector * 85
            task.wait(0.12)
            bv:Destroy()
            task.wait(0.7)
            s.dash_cd = false
        end
    end
end)

-- 4. Anti-Reload & Alerts
make_toggle("Anti-Reload", "noreload")
make_toggle("Backstab Alert", "backalert")

RunService.RenderStepped:Connect(function()
    if s.noreload then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            for _, v in pairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") and (v.Name:find("Time") or v.Name:find("Wait")) then v.Value = 0 end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.4) do
        if s.backalert and LocalPlayer.Character then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then

local hrp = LocalPlayer.Character.HumanoidRootPart
                    local en = p.Character.HumanoidRootPart
                    if (en.Position - hrp.Position).Magnitude < 25 then
                        local dot = (en.Position - hrp.Position).Unit:Dot(-hrp.CFrame.LookVector)
                        if dot > 0.7 then
                            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "BACKSTAB", Text = p.Name .. " сзади!"})
                        end
                    end
                end
            end
        end
    end
end)

-- 5. Click TP
make_toggle("Click TP (Key: T)", "click_tp")
UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.T and s.click_tp then
        LocalPlayer.Character:MoveTo(Mouse.Hit.Position)
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Lexuscript", Text = "V0.0.0 Loaded. Use '-' to minimize."})
