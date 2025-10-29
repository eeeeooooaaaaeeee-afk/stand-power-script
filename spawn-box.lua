local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.Parent = screenGui

local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0, 180, 0, 30)
stopButton.Position = UDim2.new(0, 10, 0, 10)
stopButton.Text = "ОСТАНОВИТЬ ТЕЛЕПОРТ"
stopButton.BackgroundColor3 = Color3.new(1, 0, 0)
stopButton.TextColor3 = Color3.new(1, 1, 1)
stopButton.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 180, 0, 50)
statusLabel.Position = UDim2.new(0, 10, 0, 50)
statusLabel.Text = "Статус: Активно"
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Parent = frame

-- Создание коробки (пол, стены и крыша)
local function createBox()
    local boxModel = Instance.new("Model")
    boxModel.Name = "TeleportBox"
    
    -- Размеры коробки (чуть больше персонажа)
    local width = 4
    local depth = 4
    local height = 6
    
    -- Центр коробки
    local centerX = 4.9
    local centerY = height/2 + 0.5  -- Пол на высоте 0.5, центр на половине высоты
    local centerZ = -1.0
    
    -- Пол
    local floor = Instance.new("Part")
    floor.Name = "Floor"
    floor.Size = Vector3.new(width, 1, depth)
    floor.Position = Vector3.new(centerX, 0.5, centerZ)
    floor.Anchored = true
    floor.CanCollide = true
    floor.Material = Enum.Material.Plastic
    floor.BrickColor = BrickColor.new("Bright blue")
    floor.Transparency = 0.2
    floor.Parent = boxModel
    
    -- Крыша (прозрачная для камеры)
    local ceiling = Instance.new("Part")
    ceiling.Name = "Ceiling"
    ceiling.Size = Vector3.new(width, 1, depth)
    ceiling.Position = Vector3.new(centerX, height + 0.5, centerZ)
    ceiling.Anchored = true
    ceiling.CanCollide = true
    ceiling.Material = Enum.Material.Plastic
    ceiling.BrickColor = BrickColor.new("Bright blue")
    ceiling.Transparency = 0.8  -- Более прозрачная
    ceiling.Parent = boxModel
    
    -- Стены (прозрачные для камеры)
    local wall1 = Instance.new("Part") -- Передняя стена
    wall1.Size = Vector3.new(width, height, 1)
    wall1.Position = Vector3.new(centerX, centerY, centerZ - depth/2)
    wall1.Anchored = true
    wall1.CanCollide = true
    wall1.Material = Enum.Material.Plastic
    wall1.BrickColor = BrickColor.new("Bright blue")
    wall1.Transparency = 0.8  -- Более прозрачная
    wall1.Parent = boxModel
    
    local wall2 = Instance.new("Part") -- Задняя стена
    wall2.Size = Vector3.new(width, height, 1)
    wall2.Position = Vector3.new(centerX, centerY, centerZ + depth/2)
    wall2.Anchored = true
    wall2.CanCollide = true
    wall2.Material = Enum.Material.Plastic
    wall2.BrickColor = BrickColor.new("Bright blue")
    wall2.Transparency = 0.8  -- Более прозрачная
    wall2.Parent = boxModel
    
    local wall3 = Instance.new("Part") -- Левая стена
    wall3.Size = Vector3.new(1, height, depth)
    wall3.Position = Vector3.new(centerX - width/2, centerY, centerZ)
    wall3.Anchored = true
    wall3.CanCollide = true
    wall3.Material = Enum.Material.Plastic
    wall3.BrickColor = BrickColor.new("Bright blue")
    wall3.Transparency = 0.8  -- Более прозрачная
    wall3.Parent = boxModel
    
    local wall4 = Instance.new("Part") -- Правая стена
    wall4.Size = Vector3.new(1, height, depth)
    wall4.Position = Vector3.new(centerX + width/2, centerY, centerZ)
    wall4.Anchored = true
    wall4.CanCollide = true
    wall4.Material = Enum.Material.Plastic
    wall4.BrickColor = BrickColor.new("Bright blue")
    wall4.Transparency = 0.8  -- Более прозрачная
    wall4.Parent = boxModel
    
    -- Делаем все части невидимыми для камеры
    for _, part in pairs(boxModel:GetChildren()) do
        if part:IsA("Part") then
            part.LocalTransparencyModifier = 1  -- Полностью прозрачно для локальной камеры
        end
    end
    
    -- Подсветка (видимая даже через прозрачные стены)
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 3
    pointLight.Range = 8
    pointLight.Color = Color3.new(0, 0.5, 1)
    pointLight.Parent = ceiling
    
    -- Контур для лучшей видимости границ коробки
    local function createOutline(part)
        local outline = part:Clone()
        outline.Size = outline.Size + Vector3.new(0.1, 0.1, 0.1)
        outline.Transparency = 0.9
        outline.CanCollide = false
        outline.BrickColor = BrickColor.new("Bright yellow")
        outline.Material = Enum.Material.Neon
        outline.Parent = boxModel
        outline.LocalTransparencyModifier = 0  -- Контур видим для камеры
    end
    
    -- Добавляем контуры ко всем стенам и крыше
    createOutline(wall1)
    createOutline(wall2)
    createOutline(wall3)
    createOutline(wall4)
    createOutline(ceiling)
    
    boxModel.Parent = workspace
    return boxModel, centerX, centerY, centerZ
end

-- Создаем коробку и получаем координаты центра
local boxModel, centerX, centerY, centerZ = createBox()

-- Анимация коробки (мигание света)
coroutine.wrap(function()
    while boxModel and boxModel.Parent do
        local ceiling = boxModel:FindFirstChild("Ceiling")
        local light = ceiling and ceiling:FindFirstChild("PointLight")
        if light then
            light.Enabled = not light.Enabled
        end
        wait(0.5)
    end
end)()

-- Переменные для контроля
local isActive = true
local respawnConnection
local characterAddedConnection

-- Функция телепортации и "заморозки" (через PlatformStand)
local function teleportAndFreeze(character)
    if not isActive then return end
    
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if rootPart then
        -- Телепортация в центр коробки (немного выше пола)
        rootPart.CFrame = CFrame.new(centerX, 3.2, centerZ)
        -- "Заморозка" через PlatformStand
        humanoid.PlatformStand = true
        humanoid.AutoRotate = false
        
        -- Дополнительно ограничиваем движение
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
    end
end

-- Функция "разморозки" (при смерти)
local function unfreezeOnDeath(character)
    local humanoid = character:WaitForChild("Humanoid")
    
    humanoid.Died:Connect(function()
        if not isActive then return end
        
        -- "Разморозка" при респавне
        if characterAddedConnection then
            characterAddedConnection:Disconnect()
        end
        
        characterAddedConnection = player.CharacterAdded:Connect(function(newCharacter)
            wait(0.5) -- Задержка для стабилизации
            
            local newHumanoid = newCharacter:FindFirstChild("Humanoid")
            if newHumanoid then
                -- Временно даем возможность двигаться
                newHumanoid.PlatformStand = false
                newHumanoid.AutoRotate = true
                newHumanoid.WalkSpeed = 16
                newHumanoid.JumpPower = 50
            end
            
            -- Повторная телепортация и заморозка через 1 секунду
            wait(1)
            if isActive then
                teleportAndFreeze(newCharacter)
            end
        end)
    end)
end

-- Обработчик кнопки
stopButton.MouseButton1Click:Connect(function()
    isActive = false
    statusLabel.Text = "Статус: Остановлено"
    stopButton.Text = "ТЕЛЕПОРТ ОСТАНОВЛЕН"
    stopButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
    
    -- "Разморозка" текущего персонажа
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
            humanoid.AutoRotate = true
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
    end
    
    -- Отключение соединений
    if respawnConnection then
        respawnConnection:Disconnect()
    end
    if characterAddedConnection then
        characterAddedConnection:Disconnect()
    end
    
    -- Убираем коробку
    if boxModel then
        boxModel:Destroy()
    end
end)

-- Запуск системы при появлении персонажа
respawnConnection = player.CharacterAdded:Connect(function(character)
    wait(0.5) -- Задержка для стабилизации
    if isActive then
        teleportAndFreeze(character)
        unfreezeOnDeath(character)
    end
end)

-- Запуск для текущего персонажа (если уже есть)
if player.Character then
    teleportAndFreeze(player.Character)
    unfreezeOnDeath(player.Character)
end

-- Очистка при выходе из игры
player.AncestryChanged:Connect(function()
    if not player:IsDescendantOf(game) then
        isActive = false
        if respawnConnection then
            respawnConnection:Disconnect()
        end
        if characterAddedConnection then
            characterAddedConnection:Disconnect()
        end
        if boxModel then
            boxModel:Destroy()
        end
    end
end)
