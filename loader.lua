local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    return
end

local Window = Rayfield:CreateWindow({
    Name = "stand power script Loader",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "Система управления скриптами",
    ConfigurationSaving = {
        Enabled = false
    }
})

local MainTab = Window:CreateTab("Главная", nil)

MainTab:CreateSection("Выбор версии скрипта")

MainTab:CreateButton({
    Name = "Script v1",
    Callback = function()
        Rayfield:Notify({
            Title = "Загрузка",
            Content = "Запускаем Script v1...",
            Duration = 3
        })
        
        local scriptSuccess, result = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/eeeeooooaaaaeeee-afk/stand-power-script/refs/heads/main/script-v1.lua"))()
        end)
        
        if not scriptSuccess then
            Rayfield:Notify({
                Title = "Ошибка",
                Content = "Не удалось загрузить Script v1",
                Duration = 5
            })
        end
    end
})

MainTab:CreateButton({
    Name = "Script v2",
    Callback = function()
        Rayfield:Notify({
            Title = "Загрузка",
            Content = "Запускаем Script v2...",
            Duration = 3
        })
        
        local scriptSuccess, result = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/eeeeooooaaaaeeee-afk/stand-power-script/refs/heads/main/script-v2.lua"))()
        end)
        
        if not scriptSuccess then
            Rayfield:Notify({
                Title = "Ошибка",
                Content = "Не удалось загрузить Script v2",
                Duration = 5
            })
        end
    end
})

Rayfield:Notify({
    Title = "Готово",
    Content = "Система загружена! Выберите версию скрипта.",
    Duration = 5
})
