-- LocalScript в StarterPlayerScripts

local Players = game:GetService('Players')
local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local VirtualInputManager = game:GetService('VirtualInputManager')
local TweenService = game:GetService('TweenService')
local Lighting = game:GetService('Lighting')

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Загрузка Rayfield UI Library
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    warn('Не удалось загрузить Rayfield UI')
    return
end

-- Создание главного окна
local Window = Rayfield:CreateWindow({
    Name = '🍬 Candy Farmer',
    LoadingTitle = 'Candy Farmer',
    LoadingSubtitle = 'by Scripting',
    ConfigurationSaving = {
        Enabled = true,
        FolderName = 'CandyFarmer',
        FileName = 'Config',
    },
    Discord = {
        Enabled = false,
        Invite = 'noinvitelink',
        RememberJoins = true,
    },
    KeySystem = false,
})

-- Табы
local MainTab = Window:CreateTab('Основное')
local FarmTab = Window:CreateTab('Авто-Фарм')
local SettingsTab = Window:CreateTab('Настройки')
local DebugTab = Window:CreateTab('Debug')

-- Переменные
local currentObject = nil
local farmObjects = {}
local currentFarmIndex = 1
local autoFarmEnabled = false
local farmDelay = 1
local interactDuration = 0.7
local espEnabled = false
local espHandles = {}
local walkSpeed = 16
local fullBrightEnabled = false
local originalBrightness = Lighting.Brightness
local originalAmbient = Lighting.Ambient
local originalOutdoorAmbient = Lighting.OutdoorAmbient
local noclipEnabled = false
local platform = nil
local originalCollide = {}

-- Координаты для телепортации при выключении
local SAFE_POSITION = Vector3.new(5, 4, -1)

-- Список валидных объектов для фарма
local validObjects = {
    'Candy',
    'Candy Basket',
}

-- Функция телепортации на безопасную позицию
local function teleportToSafePosition()
    local character = player.Character
    if not character then
        return false
    end

    local humanoidRootPart = character:FindFirstChild('HumanoidRootPart')
    if not humanoidRootPart then
        return false
    end

    -- Телепортируемся на безопасную позицию
    humanoidRootPart.CFrame = CFrame.new(SAFE_POSITION)
    return true
end

-- Функция создания платформы
local function createPlatform(position)
    if platform then
        platform:Destroy()
    end

    platform = Instance.new('Part')
    platform.Name = 'FarmPlatform'
    platform.Size = Vector3.new(10, 1, 10)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Material = Enum.Material.Plastic
    platform.Transparency = 0.8
    platform.BrickColor = BrickColor.new('Bright green')
    platform.Parent = workspace

    if position then
        platform.Position = position - Vector3.new(0, 4, 0)
    end
end

-- Функция удаления платформы
local function removePlatform()
    if platform then
        platform:Destroy()
        platform = nil
    end
end

-- Функция включения noclip
local function enableNoclip()
    if noclipEnabled then
        return
    end

    local character = player.Character
    if not character then
        return
    end

    -- Сохраняем оригинальные значения CanCollide
    originalCollide = {}

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA('BasePart') then
            originalCollide[part] = part.CanCollide
            part.CanCollide = false
        end
    end

    noclipEnabled = true
end

-- Функция выключения noclip
local function disableNoclip()
    if not noclipEnabled then
        return
    end

    local character = player.Character
    if not character then
        return
    end

    -- Восстанавливаем оригинальные значения CanCollide
    for part, canCollide in pairs(originalCollide) do
        if part and part.Parent then
            part.CanCollide = canCollide
        end
    end

    originalCollide = {}
    noclipEnabled = false
end

-- Функция изменения скорости персонажа
local function updateWalkSpeed()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass('Humanoid')
        if humanoid then
            humanoid.WalkSpeed = walkSpeed
        end
    end
end

-- Функция FullBright
local function toggleFullBright(enabled)
    fullBrightEnabled = enabled
    if enabled then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = originalBrightness
        Lighting.Ambient = originalAmbient
        Lighting.OutdoorAmbient = originalOutdoorAmbient
        Lighting.GlobalShadows = true
    end
end

-- ESP Functions
local function createESP(object)
    if not object or not object.Parent then
        return
    end

    local highlight = Instance.new('Highlight')
    highlight.Name = 'CandyESP'
    highlight.FillColor = Color3.fromRGB(255, 215, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 165, 0)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.Parent = object

    espHandles[object] = highlight
end

local function removeESP(object)
    if espHandles[object] then
        espHandles[object]:Destroy()
        espHandles[object] = nil
    end
end

local function updateESP()
    for object, highlight in pairs(espHandles) do
        if not object or not object.Parent then
            highlight:Destroy()
            espHandles[object] = nil
        end
    end

    if not espEnabled then
        return
    end

    for _, object in ipairs(farmObjects) do
        if object and object.Parent and not espHandles[object] then
            createESP(object)
        end
    end
end

local function toggleESP(enabled)
    espEnabled = enabled
    if not enabled then
        for object, highlight in pairs(espHandles) do
            highlight:Destroy()
        end
        espHandles = {}
    else
        updateESP()
    end
end

-- УЛУЧШЕННАЯ функция проверки валидности объекта
local function isValidObject(obj)
    if not obj then
        return false
    end

    -- Проверяем что объект не NPC и не игрок
    if obj:FindFirstAncestorOfClass('Model') then
        local model = obj:FindFirstAncestorOfClass('Model')
        if model then
            -- Проверяем на Humanoid (NPC/игроки)
            if model:FindFirstChild('Humanoid') then
                return false
            end
            -- Проверяем на Head (игроки)
            if model:FindFirstChild('Head') then
                return false
            end
        end
    end

    -- УЛУЧШЕННАЯ ПРОВЕРКА: проверяем всю иерархию объекта
    local function checkHierarchy(instance)
        if not instance then
            return false
        end

        local instanceName = instance.Name:lower()

        -- Проверяем имя текущего объекта
        for _, validName in ipairs(validObjects) do
            if instanceName:find(validName:lower(), 1, true) then
                return true
            end
        end

        -- Проверяем родителей
        local parent = instance.Parent
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

    return checkHierarchy(obj)
end

-- Функция поиска ВСЕХ объектов в определенной позиции
local function findObjectsAtPosition(position, radius)
    local foundObjects = {}
    local radiusSquared = radius * radius

    local function searchInInstance(instance)
        if instance:IsA('BasePart') then
            local distance = (instance.Position - position).Magnitude
            if distance <= radius then
                table.insert(foundObjects, instance)
            end
        end

        for _, child in ipairs(instance:GetChildren()) do
            searchInInstance(child)
        end
    end

    searchInInstance(game.Workspace)
    return foundObjects
end

-- Функция поиска Handle объектов для фарма с улучшенной фильтрацией
local function findHandleObjects()
    local foundObjects = {}
    local checkedPositions = {} -- Для предотвращения дублирования

    local function searchForHandles(instance)
        if instance:IsA('BasePart') and instance.Name == 'Handle' then
            if isValidObject(instance) then
                -- Проверяем, не находимся ли мы уже в этой позиции
                local positionKey = math.floor(instance.Position.X)
                    .. '_'
                    .. math.floor(instance.Position.Y)
                    .. '_'
                    .. math.floor(instance.Position.Z)

                if not checkedPositions[positionKey] then
                    checkedPositions[positionKey] = true
                    table.insert(foundObjects, instance)
                else
                    -- Если позиция уже проверена, ищем ВСЕ объекты в этой позиции и фильтруем только валидные
                    local objectsAtPosition =
                        findObjectsAtPosition(instance.Position, 5)
                    for _, obj in ipairs(objectsAtPosition) do
                        if obj.Name == 'Handle' and isValidObject(obj) then
                            local objPositionKey = math.floor(obj.Position.X)
                                .. '_'
                                .. math.floor(obj.Position.Y)
                                .. '_'
                                .. math.floor(obj.Position.Z)
                            if not checkedPositions[objPositionKey] then
                                checkedPositions[objPositionKey] = true
                                table.insert(foundObjects, obj)
                            end
                        end
                    end
                end
            end
        end

        for _, child in ipairs(instance:GetChildren()) do
            searchForHandles(child)
        end
    end

    searchForHandles(game.Workspace)
    return foundObjects
end

-- Функция быстрого обновления объектов (только Handle)
local function quickUpdateObjects()
    local newObjects = findHandleObjects()

    -- Удаляем объекты которых больше нет
    for i = #farmObjects, 1, -1 do
        local obj = farmObjects[i]
        if not obj or not obj.Parent then
            table.remove(farmObjects, i)
            removeESP(obj)
        end
    end

    -- Добавляем новые объекты
    for _, newObj in ipairs(newObjects) do
        local exists = false
        for _, existingObj in ipairs(farmObjects) do
            if existingObj == newObj then
                exists = true
                break
            end
        end
        if not exists then
            table.insert(farmObjects, newObj)
            if espEnabled then
                createESP(newObj)
            end
        end
    end

    return #newObjects
end

-- Улучшенная функция телепортации ПОД объект
local function teleportToObject(obj)
    if not obj then
        return false
    end

    local character = player.Character
    if not character then
        return false
    end

    local humanoidRootPart = character:FindFirstChild('HumanoidRootPart')
    if not humanoidRootPart then
        return false
    end

    local targetPosition

    -- Получаем позицию объекта
    if obj:IsA('BasePart') then
        targetPosition = obj.Position
    elseif obj:IsA('Model') and obj.PrimaryPart then
        targetPosition = obj.PrimaryPart.Position
    else
        targetPosition = obj:GetPivot().Position
    end

    -- Телепортируемся ПОД объект (на 3 studs ниже)
    local teleportPosition = targetPosition - Vector3.new(0, 3, 0)
    humanoidRootPart.CFrame = CFrame.new(teleportPosition)

    -- Создаем платформу под персонажем
    createPlatform(teleportPosition)

    return true
end

-- Функция интеракта - только зажатие E
local function autoInteract()
    -- Нажимаем и удерживаем E
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)

    -- Ждем указанное время
    wait(interactDuration)

    -- Отпускаем E
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- Улучшенная функция авто-фарма с noclip и платформой
local function startAutoFarm()
    autoFarmEnabled = true

    -- Включаем noclip при запуске
    enableNoclip()

    spawn(function()
        while autoFarmEnabled do
            -- Быстрое обновление списка объектов
            quickUpdateObjects()

            if #farmObjects == 0 then
                if FarmStatusLabel then
                    FarmStatusLabel:Set(
                        'Статус: Ожидание объектов...'
                    )
                end
                wait(2)
                continue
            end

            if currentFarmIndex > #farmObjects then
                currentFarmIndex = 1
            end

            local targetObject = farmObjects[currentFarmIndex]

            if not targetObject or not targetObject.Parent then
                table.remove(farmObjects, currentFarmIndex)
                removeESP(targetObject)
                if #farmObjects == 0 then
                    if FarmStatusLabel then
                        FarmStatusLabel:Set(
                            'Статус: Все объекты собраны!'
                        )
                    end
                    wait(2)
                    continue
                end
                continue
            end

            -- Телепортируемся ПОД объект
            local teleportSuccess = pcall(function()
                return teleportToObject(targetObject)
            end)

            if teleportSuccess then
                if FarmStatusLabel then
                    FarmStatusLabel:Set(
                        'Статус: Фармим '
                            .. currentFarmIndex
                            .. '/'
                            .. #farmObjects
                    )
                end

                -- Ждем немного перед интерактом
                wait(0.3)

                -- Выполняем интеракт (зажатие E)
                autoInteract()

                -- Ждем немного после интеракта
                wait(0.3)
            end

            currentFarmIndex = currentFarmIndex + 1
            wait(farmDelay)
        end

        -- После остановки выключаем noclip, удаляем платформу и телепортируем на безопасную позицию
        disableNoclip()
        removePlatform()
        teleportToSafePosition()

        if FarmStatusLabel then
            FarmStatusLabel:Set('Статус: Остановлен')
        end
        autoFarmEnabled = false
    end)

    return true
end

-- Создаем элементы UI
local InfoLabel = MainTab:CreateLabel(
    'Нажмите Shift + ЛКМ по конфете для получения информации'
)

local ObjectInfoSection =
    MainTab:CreateSection('Информация об объекте')

local ObjectNameLabel = MainTab:CreateLabel('Объект: Не выбран')
local ObjectClassLabel = MainTab:CreateLabel('Класс: -')
local ObjectIdLabel = MainTab:CreateLabel('ID: -')
local ObjectFarmStatus = MainTab:CreateLabel('Статус: -')

local ActionsSection = MainTab:CreateSection('Действия')

local ScanAllCandiesButton = MainTab:CreateButton({
    Name = '🔍 Сканировать все конфеты',
    Callback = function()
        local success, result = pcall(function()
            farmObjects = findHandleObjects()
            if espEnabled then
                updateESP()
            end
            Rayfield:Notify({
                Title = 'Сканирование',
                Content = 'Найдено конфет: ' .. #farmObjects,
                Duration = 3,
            })
        end)

        if not success then
            warn(
                'Ошибка при сканировании: '
                    .. tostring(result)
            )
            Rayfield:Notify({
                Title = 'Ошибка',
                Content = 'Не удалось выполнить сканирование',
                Duration = 3,
            })
        end
    end,
})

local ScanSimilarButton = MainTab:CreateButton({
    Name = '🔎 Найти похожие объекты',
    Callback = function()
        if not currentObject then
            Rayfield:Notify({
                Title = 'Ошибка',
                Content = 'Сначала выберите объект',
                Duration = 2,
            })
            return
        end

        local success, result = pcall(function()
            farmObjects = findHandleObjects()
            if espEnabled then
                updateESP()
            end
            Rayfield:Notify({
                Title = 'Поиск',
                Content = 'Найдено Handle объектов: '
                    .. #farmObjects,
                Duration = 3,
            })
        end)

        if not success then
            warn(
                'Ошибка при поиске похожих: '
                    .. tostring(result)
            )
            Rayfield:Notify({
                Title = 'Ошибка',
                Content = 'Не удалось выполнить поиск',
                Duration = 3,
            })
        end
    end,
})

local TeleportToCurrentButton = MainTab:CreateButton({
    Name = '🚀 Телепорт к объекту',
    Callback = function()
        if not currentObject then
            Rayfield:Notify({
                Title = 'Ошибка',
                Content = 'Сначала выберите объект',
                Duration = 2,
            })
            return
        end

        -- Временно включаем noclip для телепортации
        enableNoclip()

        local success = pcall(function()
            return teleportToObject(currentObject)
        end)

        if success then
            wait(0.5)
            autoInteract()
            wait(0.5)
            -- Выключаем noclip после телепортации и телепортируем на безопасную позицию
            disableNoclip()
            removePlatform()
            teleportToSafePosition()
            Rayfield:Notify({
                Title = 'Телепортация',
                Content = 'Успешно телепортирован к объекту и возвращен на базу',
                Duration = 2,
            })
        else
            -- Выключаем noclip в случае ошибки и телепортируем на безопасную позицию
            disableNoclip()
            removePlatform()
            teleportToSafePosition()
            Rayfield:Notify({
                Title = 'Ошибка',
                Content = 'Не удалось телепортироваться. Возврат на базу.',
                Duration = 2,
            })
        end
    end,
})

-- Farm Tab элементы
local FarmInfo = FarmTab:CreateLabel(
    'Автоматический фарм конфет (Handle objects only)'
)

local FarmStatusSection = FarmTab:CreateSection('Статус фарма')

local FarmStatusLabel =
    FarmTab:CreateLabel('Статус: Остановлен')

local FarmControlsSection =
    FarmTab:CreateSection('Управление фармом')

local AutoFarmToggle = FarmTab:CreateToggle({
    Name = '🔄 Включить авто-фарм',
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            if FarmStatusLabel then
                FarmStatusLabel:Set('Статус: Запускается...')
            end
            local success = pcall(function()
                return startAutoFarm()
            end)

            if success then
                Rayfield:Notify({
                    Title = 'Авто-Фарм',
                    Content = 'Авто-фарм запущен! Noclip включен.',
                    Duration = 2,
                })
            else
                if AutoFarmToggle then
                    AutoFarmToggle:Set(false)
                end
                if FarmStatusLabel then
                    FarmStatusLabel:Set(
                        'Статус: Ошибка запуска'
                    )
                end
                -- Выключаем noclip в случае ошибки и телепортируем на безопасную позицию
                disableNoclip()
                removePlatform()
                teleportToSafePosition()
                Rayfield:Notify({
                    Title = 'Ошибка',
                    Content = 'Не удалось запустить авто-фарм. Возврат на базу.',
                    Duration = 2,
                })
            end
        else
            autoFarmEnabled = false
            -- Выключаем noclip при остановке и телепортируем на безопасную позицию
            disableNoclip()
            removePlatform()
            teleportToSafePosition()
            if FarmStatusLabel then
                FarmStatusLabel:Set('Статус: Остановлен')
            end
            Rayfield:Notify({
                Title = 'Авто-Фарм',
                Content = 'Авто-фарм остановлен. Noclip выключен. Возврат на базу.',
                Duration = 2,
            })
        end
    end,
})

local FarmSettingsSection =
    FarmTab:CreateSection('Настройки фарма')

local FarmDelaySlider = FarmTab:CreateSlider({
    Name = '⏱️ Задержка между объектами (сек)',
    Range = { 0.5, 5 },
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(Value)
        farmDelay = Value
    end,
})

local InteractDurationSlider = FarmTab:CreateSlider({
    Name = '⌨️ Длительность нажатия E (сек)',
    Range = { 0.5, 2 },
    Increment = 0.1,
    CurrentValue = 0.7,
    Callback = function(Value)
        interactDuration = Value
    end,
})

-- Settings Tab элементы
local UISettingsSection =
    SettingsTab:CreateSection('Настройки интерфейса')

local ToggleUIKeybind = SettingsTab:CreateKeybind({
    Name = 'Переключение интерфейса',
    CurrentKeybind = 'RightControl',
    HoldToInteract = false,
    Callback = function(Keybind) end,
})

local PlayerSettingsSection =
    SettingsTab:CreateSection('Настройки персонажа')

local WalkSpeedSlider = SettingsTab:CreateSlider({
    Name = '🏃‍♂️ Скорость персонажа',
    Range = { 16, 200 },
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        walkSpeed = Value
        updateWalkSpeed()
    end,
})

local VisualSettingsSection =
    SettingsTab:CreateSection('Визуальные настройки')

local ESPToggle = SettingsTab:CreateToggle({
    Name = '👁️ Включить ESP конфет',
    CurrentValue = false,
    Callback = function(Value)
        toggleESP(Value)
        Rayfield:Notify({
            Title = 'ESP',
            Content = Value and 'ESP включен' or 'ESP выключен',
            Duration = 2,
        })
    end,
})

local FullBrightToggle = SettingsTab:CreateToggle({
    Name = '💡 Включить FullBright',
    CurrentValue = false,
    Callback = function(Value)
        toggleFullBright(Value)
        Rayfield:Notify({
            Title = 'FullBright',
            Content = Value and 'FullBright включен'
                or 'FullBright выключен',
            Duration = 2,
        })
    end,
})

local ObjectSettingsSection =
    SettingsTab:CreateSection('Настройки объектов')

local ValidObjectsLabel = SettingsTab:CreateParagraph({
    Title = 'Текущие имена для поиска',
    Content = table.concat(validObjects, ', '),
})

local AddObjectInput = SettingsTab:CreateInput({
    Name = '➕ Добавить имя объекта для фарма',
    PlaceholderText = 'Введите имя объекта',
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if Text and Text ~= '' then
            local alreadyExists = false
            for _, name in ipairs(validObjects) do
                if name:lower() == Text:lower() then
                    alreadyExists = true
                    break
                end
            end

            if not alreadyExists then
                table.insert(validObjects, Text)
                ValidObjectsLabel:Set({
                    Title = 'Текущие имена для поиска',
                    Content = table.concat(validObjects, ', '),
                })
                Rayfield:Notify({
                    Title = 'Успех',
                    Content = "Объект '"
                        .. Text
                        .. "' добавлен в список",
                    Duration = 3,
                })
            else
                Rayfield:Notify({
                    Title = 'Информация',
                    Content = 'Объект уже в списке',
                    Duration = 2,
                })
            end
        end
    end,
})

local RemoveObjectInput = SettingsTab:CreateInput({
    Name = '➖ Удалить имя объекта',
    PlaceholderText = 'Введите имя для удаления',
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if Text and Text ~= '' then
            local foundIndex = nil
            for i, name in ipairs(validObjects) do
                if name:lower() == Text:lower() then
                    foundIndex = i
                    break
                end
            end

            if foundIndex then
                table.remove(validObjects, foundIndex)
                ValidObjectsLabel:Set({
                    Title = 'Текущие имена для поиска',
                    Content = table.concat(validObjects, ', '),
                })
                Rayfield:Notify({
                    Title = 'Успех',
                    Content = "Объект '"
                        .. Text
                        .. "' удален из списка",
                    Duration = 3,
                })
            else
                Rayfield:Notify({
                    Title = 'Ошибка',
                    Content = 'Объект не найден в списке',
                    Duration = 2,
                })
            end
        end
    end,
})

-- Debug Tab элементы
local DebugInfoSection =
    DebugTab:CreateSection('Отладочная информация')

local ObjectsCountParagraph = DebugTab:CreateParagraph({
    Title = '📊 Статистика объектов',
    Content = "Нажмите 'Обновить' для получения статистики",
})

local RefreshObjectsButton = DebugTab:CreateButton({
    Name = '🔄 Обновить статистику объектов',
    Callback = function()
        local allObjects = findHandleObjects()
        local countByType = {}

        for _, obj in ipairs(allObjects) do
            -- Получаем имя родителя для классификации
            local parentName = obj.Parent and obj.Parent.Name or 'No Parent'
            countByType[parentName] = (countByType[parentName] or 0) + 1
        end

        local statsText = 'Всего Handle объектов: '
            .. #allObjects
            .. '\n\n'

        for name, count in pairs(countByType) do
            statsText = statsText .. '• ' .. name .. ': ' .. count .. '\n'
        end

        ObjectsCountParagraph:Set({
            Title = '📊 Статистика объектов ('
                .. #allObjects
                .. ' всего)',
            Content = statsText,
        })

        Rayfield:Notify({
            Title = 'Debug',
            Content = 'Статистика объектов обновлена',
            Duration = 2,
        })
    end,
})

local SelectedObjectDebugSection =
    DebugTab:CreateSection('Выбранный объект')

local SelectedObjectParagraph = DebugTab:CreateParagraph({
    Title = '🎯 Информация об объекте',
    Content = "Выберите объект и нажмите 'Обновить'",
})

local RefreshSelectedObjectButton = DebugTab:CreateButton({
    Name = '🔍 Обновить информацию об объекте',
    Callback = function()
        if not currentObject then
            SelectedObjectParagraph:Set({
                Title = '🎯 Информация об объекте',
                Content = '❌ Объект не выбран',
            })
            return
        end

        local target = currentObject
        local debugInfo = '📝 Основное:\n'
        debugInfo = debugInfo .. '• Имя: ' .. target.Name .. '\n'
        debugInfo = debugInfo .. '• Класс: ' .. target.ClassName .. '\n'
        debugInfo = debugInfo
            .. '• ID: '
            .. tostring(target:GetDebugId())
            .. '\n'
        debugInfo = debugInfo
            .. '• Путь: '
            .. target:GetFullName()
            .. '\n'
        debugInfo = debugInfo
            .. '• Родитель: '
            .. (target.Parent and target.Parent.Name or 'None')
            .. '\n\n'

        debugInfo = debugInfo .. '🔧 Свойства:\n'
        pcall(function()
            for _, property in pairs({
                'Position',
                'Size',
                'Material',
                'Transparency',
                'CanCollide',
                'Anchored',
            }) do
                if target[property] ~= nil then
                    debugInfo = debugInfo
                        .. '• '
                        .. property
                        .. ': '
                        .. tostring(target[property])
                        .. '\n'
                end
            end
        end)

        -- Статус фарма
        local success, isValidValue = pcall(function()
            return isValidObject(target)
        end)
        local isValid = success and isValidValue

        debugInfo = debugInfo
            .. '\n🎯 Статус фарма: '
            .. (
                isValid and '✅ ВАЛИДНЫЙ' or '❌ НЕВАЛИДНЫЙ'
            )

        SelectedObjectParagraph:Set({
            Title = '🎯 Информация: ' .. target.Name,
            Content = debugInfo,
        })
    end,
})

local SystemInfoSection =
    DebugTab:CreateSection('Системная информация')

local SystemInfoParagraph = DebugTab:CreateParagraph({
    Title = '🖥️ Системная информация',
    Content = "Нажмите 'Обновить' для получения информации",
})

local RefreshSystemInfoButton = DebugTab:CreateButton({
    Name = '💻 Обновить системную информацию',
    Callback = function()
        local systemInfo = '🎯 Основное:\n'
        systemInfo = systemInfo .. '• Игрок: ' .. player.Name .. '\n'
        systemInfo = systemInfo
            .. '• FPS: '
            .. tostring(math.floor(1 / RunService.RenderStepped:Wait()))
            .. '\n'
        systemInfo = systemInfo
            .. '• Время игры: '
            .. tostring(
                math.floor(game:GetService('Workspace').DistributedGameTime)
            )
            .. 'с\n\n'

        systemInfo = systemInfo .. '🔧 Фарм:\n'
        systemInfo = systemInfo
            .. '• Объектов в списке: '
            .. #farmObjects
            .. '\n'
        systemInfo = systemInfo
            .. '• Авто-фарм: '
            .. (autoFarmEnabled and '✅ ВКЛ' or '❌ ВЫКЛ')
            .. '\n'
        systemInfo = systemInfo
            .. '• Текущий индекс: '
            .. currentFarmIndex
            .. '\n'
        systemInfo = systemInfo
            .. '• Задержка: '
            .. farmDelay
            .. 'с\n'
        systemInfo = systemInfo
            .. '• Длительность E: '
            .. interactDuration
            .. 'с\n'
        systemInfo = systemInfo
            .. '• Noclip: '
            .. (noclipEnabled and '✅ ВКЛ' or '❌ ВЫКЛ')
            .. '\n'
        systemInfo = systemInfo
            .. '• Безопасная позиция: '
            .. tostring(SAFE_POSITION)
            .. '\n\n'

        systemInfo = systemInfo
            .. '👁️ Визуальные настройки:\n'
        systemInfo = systemInfo
            .. '• ESP: '
            .. (espEnabled and '✅ ВКЛ' or '❌ ВЫКЛ')
            .. '\n'
        systemInfo = systemInfo
            .. '• FullBright: '
            .. (fullBrightEnabled and '✅ ВКЛ' or '❌ ВЫКЛ')
            .. '\n'
        systemInfo = systemInfo .. '• Скорость: ' .. walkSpeed .. '\n'

        SystemInfoParagraph:Set({
            Title = '🖥️ Системная информация',
            Content = systemInfo,
        })
    end,
})

-- Улучшенный обработчик клика с правильной проверкой
local function onObjectClick()
    if
        UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
        or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
    then
        local target = mouse.Target
        if target then
            currentObject = target

            ObjectNameLabel:Set('Объект: ' .. target.Name)
            ObjectClassLabel:Set('Класс: ' .. target.ClassName)
            ObjectIdLabel:Set('ID: ' .. tostring(target:GetDebugId()))

            -- Правильная проверка валидности объекта
            local success, isValidValue = pcall(function()
                return isValidObject(target)
            end)
            local isValid = success and isValidValue

            ObjectFarmStatus:Set(
                'Статус: '
                    .. (
                        isValid and '✅ Подходит для фарма'
                        or '❌ Не подходит'
                    )
            )

            Rayfield:Notify({
                Title = 'Объект выбран',
                Content = target.Name
                    .. ' - '
                    .. (
                        isValid and 'Подходит для фарма'
                        or 'Не подходит для фарма'
                    ),
                Duration = 2,
            })
        end
    end
end

-- Подключаем обработчик
mouse.Button1Down:Connect(onObjectClick)

-- Автоматическое применение скорости при появлении персонажа
player.CharacterAdded:Connect(function(character)
    wait(1)
    updateWalkSpeed()
    -- Применяем noclip к новому персонажу если автофарм активен
    if autoFarmEnabled then
        wait(0.5)
        enableNoclip()
    end
end)

if player.Character then
    updateWalkSpeed()
end

-- Периодическое обновление ESP
spawn(function()
    while true do
        if espEnabled then
            updateESP()
        end
        wait(5)
    end
end)

-- Фоновая проверка объектов
spawn(function()
    while true do
        if autoFarmEnabled then
            quickUpdateObjects()
        end
        wait(10) -- Проверка каждые 10 секунд
    end
end)

-- Инициализация
Rayfield:Notify({
    Title = '🍬 Candy Farmer загружен',
    Content = 'Используйте Shift + ЛКМ по конфете для начала работы',
    Duration = 6,
})

print(
    '🍬 Candy Farmer loaded! Use Shift + Click on candies to start farming.'
)
