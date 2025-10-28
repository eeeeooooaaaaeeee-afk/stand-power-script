-- LocalScript в StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Загрузка Rayfield UI Library
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    warn("Не удалось загрузить Rayfield UI")
    return
end

-- Создание главного окна
local Window = Rayfield:CreateWindow({
   Name = "🍬 Candy Farmer",
   LoadingTitle = "Candy Farmer",
   LoadingSubtitle = "by Scripting",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "CandyFarmer",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
})

-- Табы
local MainTab = Window:CreateTab("Основное")
local FarmTab = Window:CreateTab("Авто-Фарм")
local SettingsTab = Window:CreateTab("Настройки")

-- Переменные
local currentObject = nil
local farmObjects = {}
local currentFarmIndex = 1
local autoFarmEnabled = false
local farmDelay = 1
local interactDuration = 1

-- Список валидных объектов для фарма (конфеты)
local validObjects = {
    "Конфета", "Candy", "Confetti", "Сandy", "конфета", "candy",
    "Candie", "candie", "Sweet", "sweet", "Treat", "treat",
    "CandyCorn", "candycorn", "Lolly", "lolly"
}

-- Функция проверки валидности объекта
local function isValidObject(obj)
    if not obj then return false end
    
    -- Проверяем что объект не NPC и не игрок
    if obj:FindFirstAncestorOfClass("Model") then
        local model = obj:FindFirstAncestorOfClass("Model")
        if model then
            -- Проверяем на Humanoid (NPC/игроки)
            if model:FindFirstChild("Humanoid") then
                return false
            end
            -- Проверяем на Head (игроки)
            if model:FindFirstChild("Head") then
                return false
            end
        end
    end
    
    -- Проверяем имя объекта на соответствие списку конфет
    local objectName = obj.Name:lower()
    for _, validName in ipairs(validObjects) do
        if objectName:find(validName:lower(), 1, true) then
            return true
        end
    end
    
    -- Также проверяем родителей объекта (могут быть конфеты внутри моделей)
    local parent = obj.Parent
    while parent and parent ~= game do
        local parentName = parent.Name:lower()
        for _, validName in ipairs(validObjects) do
            if parentName:find(validName:lower(), 1, true) then
                return true
            end
        end
        parent = parent.Parent
    end
    
    return false
end

-- Функция поиска объектов для фарма
local function findFarmObjects()
    local foundObjects = {}
    local checked = {}
    
    local function searchInInstance(instance)
        if checked[instance] then return end
        checked[instance] = true
        
        if isValidObject(instance) then
            table.insert(foundObjects, instance)
        end
        
        for _, child in ipairs(instance:GetChildren()) do
            searchInInstance(child)
        end
    end
    
    searchInInstance(game.Workspace)
    return foundObjects
end

-- Функция поиска объектов по выбранному образцу
local function findSimilarObjects(targetObject)
    local foundObjects = {}
    local checked = {}
    
    -- Получаем имя для поиска из объекта или его родителей
    local targetNames = {targetObject.Name:lower()}
    
    local parent = targetObject.Parent
    while parent and parent ~= game do
        table.insert(targetNames, parent.Name:lower())
        parent = parent.Parent
    end
    
    local function searchInInstance(instance)
        if checked[instance] then return end
        checked[instance] = true
        
        if instance ~= targetObject and isValidObject(instance) then
            -- Проверяем совпадение имен
            local instanceName = instance.Name:lower()
            for _, targetName in ipairs(targetNames) do
                if instanceName:find(targetName, 1, true) then
                    table.insert(foundObjects, instance)
                    break
                end
            end
            
            -- Также проверяем родителей
            local parent = instance.Parent
            while parent and parent ~= game do
                local parentName = parent.Name:lower()
                for _, targetName in ipairs(targetNames) do
                    if parentName:find(targetName, 1, true) then
                        table.insert(foundObjects, instance)
                        break
                    end
                end
                parent = parent.Parent
            end
        end
        
        for _, child in ipairs(instance:GetChildren()) do
            searchInInstance(child)
        end
    end
    
    searchInInstance(game.Workspace)
    return foundObjects
end

local function teleportToPosition(position)
    local character = player.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    humanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
    return true
end

local function teleportToObject(obj)
    if not obj then return false end
    
    local targetPosition
    
    if obj:IsA("BasePart") then
        targetPosition = obj.Position
    elseif obj:IsA("Model") and obj.PrimaryPart then
        targetPosition = obj.PrimaryPart.Position
    else
        -- Если это часть модели, используем ее позицию
        targetPosition = obj:GetPivot().Position
    end
    
    return teleportToPosition(targetPosition)
end

-- Функция авто-интеракта
local function autoInteract()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        wait(interactDuration)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end

-- Функция авто-фарма
local function startAutoFarm()
    if #farmObjects == 0 then
        Rayfield:Notify({
            Title = "Ошибка",
            Content = "Нет объектов для фарма",
            Duration = 3
        })
        return false
    end
    
    autoFarmEnabled = true
    currentFarmIndex = 1
    
    spawn(function()
        while autoFarmEnabled and #farmObjects > 0 do
            if currentFarmIndex > #farmObjects then
                currentFarmIndex = 1
            end
            
            local targetObject = farmObjects[currentFarmIndex]
            
            -- Проверяем что объект еще существует
            if not targetObject or not targetObject.Parent then
                table.remove(farmObjects, currentFarmIndex)
                if #farmObjects == 0 then
                    autoFarmEnabled = false
                    Rayfield:Notify({
                        Title = "Авто-Фарм",
                        Content = "Все объекты собраны!",
                        Duration = 3
                    })
                    break
                end
                continue
            end
            
            -- Телепортируемся к объекту
            local success = pcall(function()
                return teleportToObject(targetObject)
            end)
            
            if success then
                -- Ждем перед интерактом
                wait(0.5)
                
                -- Выполняем интеракт
                autoInteract()
                
                -- Обновляем статус
                if FarmStatusLabel then
                    FarmStatusLabel:Set("Статус: Фармим " .. currentFarmIndex .. "/" .. #farmObjects)
                end
            end
            
            currentFarmIndex = currentFarmIndex + 1
            
            -- Задержка между объектами
            wait(farmDelay)
        end
        
        -- После остановки
        if FarmStatusLabel then
            FarmStatusLabel:Set("Статус: Остановлен")
        end
        if AutoFarmToggle then
            AutoFarmToggle:Set(false)
        end
        autoFarmEnabled = false
    end)
    
    return true
end

-- Создаем элементы UI
local InfoLabel = MainTab:CreateLabel("Нажмите Shift + ЛКМ по конфете для получения информации")

local ObjectInfoSection = MainTab:CreateSection("Информация об объекте")

local ObjectNameLabel = MainTab:CreateLabel("Объект: Не выбран")
local ObjectClassLabel = MainTab:CreateLabel("Класс: -")
local ObjectIdLabel = MainTab:CreateLabel("ID: -")
local ObjectFarmStatus = MainTab:CreateLabel("Статус: -")

local DetailedInfo = MainTab:CreateParagraph({
    Title = "Детальная информация",
    Content = "Выберите объект для просмотра информации"
})

local ActionsSection = MainTab:CreateSection("Действия")

local ScanAllCandiesButton = MainTab:CreateButton({
    Name = "🔍 Сканировать все конфеты",
    Callback = function()
        local success, result = pcall(function()
            farmObjects = findFarmObjects()
            if FarmObjectsLabel then
                FarmObjectsLabel:Set("Найдено объектов: " .. #farmObjects)
            end
            Rayfield:Notify({
                Title = "Сканирование",
                Content = "Найдено конфет: " .. #farmObjects,
                Duration = 3
            })
        end)
        
        if not success then
            warn("Ошибка при сканировании: " .. tostring(result))
            Rayfield:Notify({
                Title = "Ошибка",
                Content = "Не удалось выполнить сканирование",
                Duration = 3
            })
        end
    end
})

local ScanSimilarButton = MainTab:CreateButton({
    Name = "🔎 Найти похожие объекты",
    Callback = function()
        if not currentObject then
            Rayfield:Notify({
                Title = "Ошибка",
                Content = "Сначала выберите объект",
                Duration = 2
            })
            return
        end
        
        local success, result = pcall(function()
            farmObjects = findSimilarObjects(currentObject)
            if FarmObjectsLabel then
                FarmObjectsLabel:Set("Найдено объектов: " .. #farmObjects)
            end
            Rayfield:Notify({
                Title = "Поиск",
                Content = "Найдено похожих объектов: " .. #farmObjects,
                Duration = 3
            })
        end)
        
        if not success then
            warn("Ошибка при поиске похожих: " .. tostring(result))
            Rayfield:Notify({
                Title = "Ошибка",
                Content = "Не удалось выполнить поиск",
                Duration = 3
            })
        end
    end
})

local TeleportToCurrentButton = MainTab:CreateButton({
    Name = "🚀 Телепорт к объекту",
    Callback = function()
        if not currentObject then
            Rayfield:Notify({
                Title = "Ошибка",
                Content = "Сначала выберите объект",
                Duration = 2
            })
            return
        end
        
        local success = pcall(function()
            return teleportToObject(currentObject)
        end)
        
        if success then
            autoInteract()
            Rayfield:Notify({
                Title = "Телепортация",
                Content = "Успешно телепортирован к объекту",
                Duration = 2
            })
        else
            Rayfield:Notify({
                Title = "Ошибка",
                Content = "Не удалось телепортироваться",
                Duration = 2
            })
        end
    end
})

-- Farm Tab элементы
local FarmInfo = FarmTab:CreateLabel("Автоматический фарм конфет")

local FarmStatusSection = FarmTab:CreateSection("Статус фарма")

local FarmObjectsLabel = FarmTab:CreateLabel("Найдено объектов: 0")
local FarmStatusLabel = FarmTab:CreateLabel("Статус: Остановлен")

local FarmControlsSection = FarmTab:CreateSection("Управление фармом")

local AutoFarmToggle = FarmTab:CreateToggle({
    Name = "🔄 Включить авто-фарм",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            local success = pcall(function()
                return startAutoFarm()
            end)
            
            if success then
                Rayfield:Notify({
                    Title = "Авто-Фарм",
                    Content = "Авто-фарм запущен!",
                    Duration = 2
                })
            else
                AutoFarmToggle:Set(false)
                Rayfield:Notify({
                    Title = "Ошибка",
                    Content = "Не удалось запустить авто-фарм",
                    Duration = 2
                })
            end
        else
            autoFarmEnabled = false
            FarmStatusLabel:Set("Статус: Остановлен")
            Rayfield:Notify({
                Title = "Авто-Фарм",
                Content = "Авто-фарм остановлен",
                Duration = 2
            })
        end
    end
})

local FarmSettingsSection = FarmTab:CreateSection("Настройки фарма")

local FarmDelaySlider = FarmTab:CreateSlider({
    Name = "⏱️ Задержка между объектами (сек)",
    Range = {0.5, 5},
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(Value)
        farmDelay = Value
    end
})

local InteractDurationSlider = FarmTab:CreateSlider({
    Name = "⌨️ Длительность нажатия E (сек)",
    Range = {0.5, 3},
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(Value)
        interactDuration = Value
    end
})

local FarmActionsSection = FarmTab:CreateSection("Действия")

local AddToFarmListButton = FarmTab:CreateButton({
    Name = "➕ Добавить объект в список фарма",
    Callback = function()
        if not currentObject then
            Rayfield:Notify({
                Title = "Ошибка",
                Content = "Сначала выберите объект",
                Duration = 2
            })
            return
        end
        
        local isValid = pcall(function()
            return isValidObject(currentObject)
        end)
        
        if isValid then
            local alreadyExists = false
            for _, obj in ipairs(farmObjects) do
                if obj == currentObject then
                    alreadyExists = true
                    break
                end
            end
            
            if not alreadyExists then
                table.insert(farmObjects, currentObject)
                FarmObjectsLabel:Set("Найдено объектов: " .. #farmObjects)
                Rayfield:Notify({
                    Title = "Успех",
                    Content = "Объект добавлен в список фарма",
                    Duration = 2
                })
            else
                Rayfield:Notify({
                    Title = "Информация",
                    Content = "Объект уже в списке фарма",
                    Duration = 2
                })
            end
        else
            Rayfield:Notify({
                Title = "Ошибка",
                Content = "Объект не подходит для фарма",
                Duration = 2
            })
        end
    end
})

local ClearFarmListButton = FarmTab:CreateButton({
    Name = "🧹 Очистить список фарма",
    Callback = function()
        farmObjects = {}
        FarmObjectsLabel:Set("Найдено объектов: 0")
        FarmStatusLabel:Set("Статус: Остановлен")
        autoFarmEnabled = false
        AutoFarmToggle:Set(false)
        Rayfield:Notify({
            Title = "Очистка",
            Content = "Список фарма очищен",
            Duration = 2
        })
    end
})

-- Settings Tab элементы
local UISettingsSection = SettingsTab:CreateSection("Настройки интерфейса")

local ToggleUIKeybind = SettingsTab:CreateKeybind({
    Name = "Переключение интерфейса",
    CurrentKeybind = "RightControl",
    HoldToInteract = false,
    Callback = function(Keybind)
        -- Пустой callback чтобы избежать ошибок
    end
})

local ObjectSettingsSection = SettingsTab:CreateSection("Настройки объектов")

local ValidObjectsLabel = SettingsTab:CreateLabel("Искомые объекты: Конфета, Candy, Confetti, Sweet")

local AddObjectInput = SettingsTab:CreateInput({
    Name = "Добавить имя объекта для фарма",
    PlaceholderText = "Введите имя объекта",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if Text and Text ~= "" then
            local alreadyExists = false
            for _, name in ipairs(validObjects) do
                if name:lower() == Text:lower() then
                    alreadyExists = true
                    break
                end
            end
            
            if not alreadyExists then
                table.insert(validObjects, Text)
                Rayfield:Notify({
                    Title = "Успех",
                    Content = "Объект '" .. Text .. "' добавлен в список",
                    Duration = 3
                })
            else
                Rayfield:Notify({
                    Title = "Информация",
                    Content = "Объект уже в списке",
                    Duration = 2
                })
            end
        end
    end
})

-- Обработчик клика
local function onObjectClick()
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
        local target = mouse.Target
        if target then
            currentObject = target
            
            -- Обновляем основную информацию
            ObjectNameLabel:Set("Объект: " .. target.Name)
            ObjectClassLabel:Set("Класс: " .. target.ClassName)
            ObjectIdLabel:Set("ID: " .. tostring(target:GetDebugId()))
            
            -- Проверяем валидность
            local isValid = pcall(function()
                return isValidObject(target)
            end)
            
            ObjectFarmStatus:Set("Статус: " .. (isValid and "✅ Подходит для фарма" or "❌ Не подходит"))
            
            -- Обновляем детальную информацию
            local objectInfo = "Имя: " .. target.Name .. "\n"
            objectInfo = objectInfo .. "Класс: " .. target.ClassName .. "\n"
            objectInfo = objectInfo .. "ID: " .. tostring(target:GetDebugId()) .. "\n\n"
            
            if target:IsA("BasePart") then
                objectInfo = objectInfo .. "Позиция: " .. tostring(target.Position) .. "\n"
                objectInfo = objectInfo .. "Размер: " .. tostring(target.Size) .. "\n"
            end
            
            objectInfo = objectInfo .. "\nСтатус: " .. (isValid and "✅ Подходит для фарма" or "❌ Не подходит")
            
            DetailedInfo:SetTitle("Информация: " .. target.Name)
            DetailedInfo:SetContent(objectInfo)
            
            Rayfield:Notify({
                Title = "Объект выбран",
                Content = target.Name .. " - " .. (isValid and "Подходит для фарма" or "Не подходит для фарма"),
                Duration = 2
            })
        end
    end
end

-- Подключаем обработчик
mouse.Button1Down:Connect(onObjectClick)

-- Инициализация
Rayfield:Notify({
    Title = "🍬 Candy Farmer загружен",
    Content = "Используйте Shift + ЛКМ по конфете для начала работы",
    Duration = 6
})

print("🍬 Candy Farmer loaded! Use Shift + Click on candies to start farming.")
