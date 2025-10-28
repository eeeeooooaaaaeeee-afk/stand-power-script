local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Ошибка",
        Text = "Не удалось загрузить Rayfield",
        Duration = 5
    })
    return
end

local Window = Rayfield:CreateWindow({
    Name = "Script Loader",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "by Script Developer",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ScriptLoader",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
})

local MainTab = Window:CreateTab("Главная", "rbxassetid://4483345998")

local Section = MainTab:CreateSection("Выбор скрипта")

local Button1 = MainTab:CreateButton({
    Name = "Script v1",
    Callback = function()
        Rayfield:Notify({
            Title = "Загрузка",
            Content = "Загружаем Script v1...",
            Duration = 3,
            Image = 4483362458
        })
        
        local success, result = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/eeeeooooaaaaeeee-afk/stand-power-script/refs/heads/main/script-v1.txt?token=GHSAT0AAAAAADMMYNXEHUHW3URNFBJXUDCE2IA3KYA")
        end)
        
        if success then
            loadstring(result)()
            Rayfield:Notify({
                Title = "Успех",
                Content = "Script v1 успешно загружен!",
                Duration = 5,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Ошибка",
                Content = "Не удалось загрузить Script v1: " .. tostring(result),
                Duration = 5,
                Image = 4483362458
            })
        end
    end,
})

local Button2 = MainTab:CreateButton({
    Name = "Script v2",
    Callback = function()
        Rayfield:Notify({
            Title = "Загрузка",
            Content = "Загружаем Script v2...",
            Duration = 3,
            Image = 4483362458
        })
        
        -- Замените "НАПИШУ ЕГО ПОЗЖЕ" на реальный URL когда будет готов
        local scriptUrl = "НАПИШУ ЕГО ПОЗЖЕ"
        
        if scriptUrl == "НАПИШУ ЕГО ПОЗЖЕ" then
            Rayfield:Notify({
                Title = "Внимание",
                Content = "URL для Script v2 еще не установлен!",
                Duration = 5,
                Image = 4483362458
            })
            return
        end
        
        local success, result = pcall(function()
            return game:HttpGet(scriptUrl)
        end)
        
        if success then
            loadstring(result)()
            Rayfield:Notify({
                Title = "Успех",
                Content = "Script v2 успешно загружен!",
                Duration = 5,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Ошибка",
                Content = "Не удалось загрузить Script v2: " .. tostring(result),
                Duration = 5,
                Image = 4483362458
            })
        end
    end,
})

local InfoSection = MainTab:CreateSection("Информация")

MainTab:CreateLabel("Выберите версию скрипта для загрузки")
MainTab:CreateLabel("Script v1 - текущая версия")
MainTab:CreateLabel("Script v2 - будет доступен позже")

Rayfield:Notify({
    Title = "Script Loader",
    Content = "Интерфейс успешно загружен!",
    Duration = 5,
    Image = 4483362458
})
