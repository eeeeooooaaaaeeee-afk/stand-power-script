                                                                                 local v0=game:        
                                                                        GetService("Players");local v1=game:GetService( 
                                                                    "UserInputService");local v2=game:GetService("RunService");   
                                                                local v3=game:GetService("VirtualInputManager");local v4=game:          
                                                            GetService("TweenService");local v5=game:GetService("Lighting");local v6=v0.  
                                                          LocalPlayer;local v7=v6:GetMouse();local v8,v9=pcall(function() return loadstring 
                                                        (game:HttpGet("https://sirius.menu/rayfield"))();end);if  not v8 then warn(           
                                                      "Не удалось загрузить Rayfield UI");return;end local v10=v9:CreateWindow({Name=           
                                                    "🍬 Candy Farmer",LoadingTitle="Candy Farmer",LoadingSubtitle="by Scripting",                 
                                                  ConfigurationSaving={Enabled=true,FolderName="CandyFarmer",FileName="Config"},Discord={Enabled=   
                                                  false,Invite="noinvitelink",RememberJoins=true},KeySystem=false});local v11=v10:CreateTab(          
                                                "Основное");local v12=v10:CreateTab("Авто-Фарм");local v13=v10:CreateTab("Настройки");local v14=v10:    
                                                CreateTab("Debug");local v15=nil;local v16={};local v17=1;local v18=false;local v19=1;local v20=0.7;local 
                                               v21=false;local v22={};local v23=16;local v24=false;local v25=v5.Brightness;local v26=v5.Ambient;local v27=  
                                              v5.OutdoorAmbient;local v28=false;local v29=nil;local v30={};local v31=Vector3.new(5,4, -1);local v32={       
                                            "Candy","Candy Basket"};local function v33() local v90=v6.Character;if  not v90 then return false;end local v91=  
                                            v90:FindFirstChild("HumanoidRootPart");if  not v91 then return false;end v91.CFrame=CFrame.new(v31);return true;end 
                                           local function v34(v93) if v29 then v29:Destroy();end v29=Instance.new("Part");v29.Name="FarmPlatform";v29.Size=       
                                          Vector3.new(10,1,10);v29.Anchored=true;v29.CanCollide=true;v29.Material=Enum.Material.Plastic;v29.Transparency=0.8;v29.   
                                          BrickColor=BrickColor.new("Bright green");v29.Parent=workspace;if v93 then v29.Position=v93-Vector3.new(0,4,0) ;end end     
                                          local function v35() if v29 then v29:Destroy();v29=nil;end end local function v36() if v28 then return;end local v103=v6.   
                                        Character;if  not v103 then return;end v30={};for v159,v160 in ipairs(v103:GetDescendants()) do if v160:IsA("BasePart") then    
                                        v30[v160]=v160.CanCollide;v160.CanCollide=false;end end v28=true;end  --[[==============================]]local function v37() if 
                                          not v28 then return;end local v104=v6.Character;if  not   --[[============================================]]v104 then return;   
                                        end for v161,v162 in pairs(v30) do if (v161 and v161.   --[[======================================================]]Parent) then    
                                      v161.CanCollide=v162;end end v30={};v28=false;end     --[[==========================================================]]local function    
                                      v38() local v105=v6.Character;if v105 then local    --[[==============================================================]]v184=v105:      
                                      FindFirstChildOfClass("Humanoid");if v184 then v184 --[[================================================================]].WalkSpeed=v23; 
                                      end end end local function v39(v106) v24=v106;if    --[[==================================================================]]v106 then v5. 
                                      Brightness=2;v5.Ambient=Color3.new(1,1,1);v5.       --[[==================================================================]]OutdoorAmbient=   
                                    Color3.new(1,1,1);v5.GlobalShadows=false;else v5.     --[[====================================================================]]Brightness=   
                    v25;v5.Ambient=v26;v5.OutdoorAmbient=v27;v5.GlobalShadows=true;end    --[[====================================================================]]end local       
              function v40(v107) if ( not v107 or  not v107.Parent) then return;end local --[[======================================================================]] v108=        
            Instance.new("Highlight");v108.Name="CandyESP";v108.FillColor=Color3.fromRGB( --[[======================================================================]]255,215,0);   
          v108.OutlineColor=Color3.fromRGB(255,165,0);v108.FillTransparency=0.3;v108.     --[[======================================================================]]              
        OutlineTransparency=0;v108.Parent=v107;v22[v107]=v108;end local function v41(v116 --[[======================================================================]]) if v22[v116 
        ] then v22[v116]:Destroy();v22[v116]=nil;end end local function v42() for v163,   --[[======================================================================]]v164 in pairs 
      (v22) do if ( not v163 or  not v163.Parent) then v164:Destroy();v22[v163]=nil;end   --[[======================================================================]]end if  not   
      v21 then return;end for v165,v166 in ipairs(v16) do if (v166 and v166.Parent and  not --[[==================================================================]] v22[v166])     
      then v40(v166);end end end local function v43(v117) v21=v117;if  not v117 then for    --[[================================================================]]v218,v219 in      
    pairs(v22) do v219:Destroy();end v22={};else v42();end end local function v44(v118) if  --[[==============================================================]]  not v118 then   
    return false;end if v118:FindFirstAncestorOfClass("Model") then local v194=v118:          --[[==========================================================]]                    
    FindFirstAncestorOfClass("Model");if v194 then if v194:FindFirstChild("Humanoid") then      --[[====================================================]]return false;end if     
    v194:FindFirstChild("Head") then return false;end end end local function v119(v167) if  not   --[[==============================================]]v167 then return false;   
    end local v168=v167.Name:lower();for v195,v196 in ipairs(v32) do if v168:find(v196:lower(),1,true --[[====================================]]) then return true;end end    
    local v169=v167.Parent;while v169 and (v169~=game)  do local v197=v169.Name:lower();for v220,v221 in  --[[========================]]ipairs(v32) do if v197:find(v221:     
    lower(),1,true) then return true;end end v169=v169.Parent;end return false;end return v119(v118);end local function v45(v120,v121) local v122={};local v123=v121 * v121 
   ;local function v124(v170) if v170:IsA("BasePart") then local v222=(v170.Position-v120).Magnitude;if (v222<=v121) then table.insert(v122,v170);end end for v199,v200   
  in ipairs(v170:GetChildren()) do v124(v200);end end v124(game.Workspace);return v122;end local function v46() local v125={};local v126={};local function v127(v171)   
  if (v171:IsA("BasePart") and (v171.Name=="Handle")) then if v44(v171) then local v233=math.floor(v171.Position.X)   .. "_"   .. math.floor(v171.Position.Y)   .. "_"    
  .. math.floor(v171.Position.Z) ;if  not v126[v233] then v126[v233]=true;table.insert(v125,v171);else local v235=v45(v171.Position,5);for v236,v237 in ipairs(v235) do   
  if ((v237.Name=="Handle") and v44(v237)) then local v238=math.floor(v237.Position.X)   .. "_"   .. math.floor(v237.Position.Y)   .. "_"   .. math.floor(v237.Position.Z 
  ) ;if  not v126[v238] then v126[v238]=true;table.insert(v125,v237);end end end end end end for v201,v202 in ipairs(v171:GetChildren()) do v127(v202);end end v127(game. 
  Workspace);return v125;end local function v47() local v128=v46();for v172= #v16,1, -1 do local v173=v16[v172];if ( not v173 or  not v173.Parent) then table.remove(v16, 
  v172);v41(v173);end end for v174,v175 in ipairs(v128) do local v176=false;for v203,v204 in ipairs(v16) do if (v204==v175) then v176=true;break;end end if  not v176     
  then table.insert(v16,v175);if v21 then v40(v175);end end end return  #v128;end local function v48(v129) if  not v129 then return false;end local v130=v6.Character;if  
    not v130 then return false;end local v131=v130:FindFirstChild("HumanoidRootPart");if  not v131 then return false;end local v132;if v129:IsA("BasePart") then v132=    
  v129.Position;elseif (v129:IsA("Model") and v129.PrimaryPart) then v132=v129.PrimaryPart.Position;else v132=v129:GetPivot().Position;end local v133=v132-Vector3.new(0, 
  3,0) ;v131.CFrame=CFrame.new(v133);v34(v133);return true;end local function v49() v3:SendKeyEvent(true,Enum.KeyCode.E,false,game);wait(v20);v3:SendKeyEvent(false,Enum.   
  KeyCode.E,false,game);end local function v50() v18=true;v36();spawn(function() while v18 do v47();if ( #v16==0) then if FarmStatusLabel then FarmStatusLabel:Set(         
  "Статус: Ожидание объектов...");end wait(2);continue;end if (v17> #v16) then v17=1;end local v206=v16[v17];if ( not v206 or  not v206.Parent) then table.remove(v16,v17); 
  v41(v206);if ( #v16==0) then if FarmStatusLabel then FarmStatusLabel:Set("Статус: Все объекты собраны!");end wait(2);continue;end continue;end local v207=pcall(function( 
  ) return v48(v206);end);if v207 then if FarmStatusLabel then FarmStatusLabel:Set("Статус: Фармим "   .. v17   .. "/"   ..  #v16 );end wait(0.3);v49();wait(0.3);end v17=  
  v17 + 1 ;wait(v19);end v37();v35();v33();if FarmStatusLabel then FarmStatusLabel:Set("Статус: Остановлен");end v18=false;end);return true;end local v51=v11:CreateLabel(  
  "Нажмите Shift + ЛКМ по конфете для получения информации");local v52=v11:CreateSection("Информация об объекте");local v53=v11:CreateLabel("Объект: Не выбран");local v54= 
  v11:CreateLabel("Класс: -");local v55=v11:CreateLabel("ID: -");local v56=v11:CreateLabel("Статус: -");local v57=v11:CreateSection("Действия");local v58=v11:CreateButton( 
  {Name="🔍 Сканировать все конфеты",Callback=function() local v135,v136=pcall(function() v16=v46();if v21 then v42();end v9:Notify({Title="Сканирование",Content=          
  "Найдено конфет: "   ..  #v16 ,Duration=3});end);if  not v135 then warn("Ошибка при сканировании: "   .. tostring(v136) );v9:Notify({Title="Ошибка",Content=              
  "Не удалось выполнить сканирование",Duration=3});end end});local v59=v11:CreateButton({Name="🔎 Найти похожие объекты",Callback=function() if  not v15 then v9:Notify({   
  Title="Ошибка",Content="Сначала выберите объект",Duration=2});return;end local v137,v138=pcall(function() v16=v46();if v21 then v42();end v9:Notify({Title="Поиск",       
  Content="Найдено Handle объектов: "   ..  #v16 ,Duration=3});end);if  not v137 then warn("Ошибка при поиске похожих: "   .. tostring(v138) );v9:Notify({Title="Ошибка",   
  Content="Не удалось выполнить поиск",Duration=3});end end});local v60=v11:CreateButton({Name="🚀 Телепорт к объекту",Callback=function() if  not v15 then v9:Notify({   
  Title="Ошибка",Content="Сначала выберите объект",Duration=2});return;end v36();local v139=pcall(function() return v48(v15);end);if v139 then wait(0.5);v49();wait(0.5); 
  v37();v35();v33();v9:Notify({Title="Телепортация",Content="Успешно телепортирован к объекту и возвращен на базу",Duration=2});else v37();v35();v33();v9:Notify({Title=  
    "Ошибка",Content="Не удалось телепортироваться. Возврат на базу.",Duration=2});end end});local v61=v12:CreateLabel("Автоматический фарм конфет (Handle objects only)" 
    );local v62=v12:CreateSection("Статус фарма");local v63=v12:CreateLabel("Статус: Остановлен");local v64=v12:CreateSection("Управление фармом");local v65=v12:         
    CreateToggle({Name="🔄 Включить авто-фарм",CurrentValue=false,Callback=function(v140) if v140 then if v63 then v63:Set("Статус: Запускается...");end local v208=pcall 
    (function() return v50();end);if v208 then v9:Notify({Title="Авто-Фарм",Content="Авто-фарм запущен! Noclip включен.",Duration=2});else if AutoFarmToggle then         
      AutoFarmToggle:Set(false);end if v63 then v63:Set("Статус: Ошибка запуска");end v37();v35();v33();v9:Notify({Title="Ошибка",Content=                              
      "Не удалось запустить авто-фарм. Возврат на базу.",Duration=2});end else v18=false;v37();v35();v33();if v63 then v63:Set("Статус: Остановлен");end v9:Notify({    
      Title="Авто-Фарм",Content="Авто-фарм остановлен. Noclip выключен. Возврат на базу.",Duration=2});end end});local v66=v12:CreateSection("Настройки фарма");local   
        v67=v12:CreateSlider({Name="⏱️ Задержка между объектами (сек)",Range={0.5,5},Increment=0.1,CurrentValue=1,Callback=function(v141) v19=v141;end});local v68=v12: 
        CreateSlider({Name="⌨️ Длительность нажатия E (сек)",Range={0.5,2},Increment=0.1,CurrentValue=0.7,Callback=function(v142) v20=v142;end});local v69=v13:         
        CreateSection("Настройки интерфейса");local v70=v13:CreateKeybind({Name="Переключение интерфейса",CurrentKeybind="RightControl",HoldToInteract=false,Callback=  
          function(v143) end});local v71=v13:CreateSection("Настройки персонажа");local v72=v13:CreateSlider({Name="🏃‍♂️ Скорость персонажа",Range={16,200},         
            Increment=1,CurrentValue=16,Callback=function(v144) v23=v144;v38();end});local v73=v13:CreateSection("Визуальные настройки");local v74=v13:CreateToggle({ 
              Name="👁️ Включить ESP конфет",CurrentValue=false,Callback=function(v145) v43(v145);v9:Notify({Title="ESP",Content=(v145 and "ESP включен") or          
                "ESP выключен" ,Duration=2});end});local v75=v13:CreateToggle({Name="💡 Включить FullBright",CurrentValue=false,Callback=function(v146) v39(v146);v9: 
                  Notify({Title="FullBright",Content=(v146 and "FullBright включен") or "FullBright выключен" ,Duration=2});end});local v76=v13:CreateSection(      
                      "Настройки объектов");local v77=v13:CreateParagraph({Title="Текущие имена для поиска",Content=table.concat(v32,", ")});local v78=v13:         
                                  CreateInput({Name="➕ Добавить имя объекта для фарма",PlaceholderText="Введите имя объекта",RemoveTextAfterFocusLost=false,        
                                      Callback=function(v147) if (v147 and (v147~="")) then local v209=false;for v223,v224 in ipairs(v32) do if (v224:lower()==v147 
                                      :lower()) then v209=true;break;end end if  not v209 then              table.insert(v32,v147);v77:Set({Title=                  
                                      "Текущие имена для поиска",Content=table.concat(v32,", ")});          v9:Notify({Title="Успех",Content="Объект '"   .. v147 
                                         .. "' добавлен в список" ,Duration=3});else v9:Notify({            Title="Информация",Content="Объект уже в списке",     
                                      Duration=2});end end end});local v79=v13:CreateInput({Name=           "➖ Удалить имя объекта",PlaceholderText=              
                                      "Введите имя для удаления",RemoveTextAfterFocusLost=false,              Callback=function(v148) if (v148 and (v148~=""))    
                                      then local v210=nil;for v225,v226 in ipairs(v32) do if (v226:           lower()==v148:lower()) then v210=v225;break;end end 
                                       if v210 then table.remove(v32,v210);v77:Set({Title=                    "Текущие имена для поиска",Content=table.concat(  
                                        v32,", ")});v9:Notify({Title="Успех",Content="Объект '"               .. v148   .. "' удален из списка" ,Duration=3});  
                                        else v9:Notify({Title="Ошибка",Content=                                 "Объект не найден в списке",Duration=2});end    
                                        end end});local v80=v14:CreateSection(                                  "Отладочная информация");local v81=v14:       
                                        CreateParagraph({Title="📊 Статистика объектов",Content=                "Нажмите 'Обновить' для получения статистики" 
                                        });local v82=v14:CreateButton({Name=                                      "🔄 Обновить статистику объектов",        
                                        Callback=function() local v149=v46();local v150={};for                    v177,v178 in ipairs(v149) do local v179=( 
                                          v178.Parent and v178.Parent.Name) or "No Parent" ;v150[                   v179]=(v150[v179] or 0) + 1 ;end      
                                          local v151="Всего Handle объектов: "   ..  #v149   ..                        "\n\n" ;for v181,v182 in pairs 
                                            (v150) do v151=v151   .. "• "   .. v181   .. ": "                              .. v182   .. "\n" ;end 
                                             v81:Set({Title="📊 Статистика объектов ("   ..                                   #v149   ..  
                                              " всего)" ,Content=v151});v9:Notify({Title=   
                                                "Debug",Content=                          
                                                    "Статистика объектов обновлена",    
                                                          Duration=2});end});     


local v83=v14:CreateSection("Выбранный объект");local v84=v14:CreateParagraph({Title="🎯 Информация об объекте",Content="Выберите объект и нажмите 'Обновить'"});local v85=v14:CreateButton({Name="🔍 Обновить информацию об объекте",Callback=function() if  not v15 then v84:Set({Title="🎯 Информация об объекте",Content="❌ Объект не выбран"});return;end local v152=v15;local v153="📝 Основное:\n";v153=v153   .. "• Имя: "   .. v152.Name   .. "\n" ;v153=v153   .. "• Класс: "   .. v152.ClassName   .. "\n" ;v153=v153   .. "• ID: "   .. tostring(v152:GetDebugId())   .. "\n" ;v153=v153   .. "• Путь: "   .. v152:GetFullName()   .. "\n" ;v153=v153   .. "• Родитель: "   .. ((v152.Parent and v152.Parent.Name) or "None")   .. "\n\n" ;v153=v153   .. "🔧 Свойства:\n" ;pcall(function() for v211,v212 in pairs({"Position","Size","Material","Transparency","CanCollide","Anchored"}) do if (v152[v212]~=nil) then v153=v153   .. "• "   .. v212   .. ": "   .. tostring(v152[v212])   .. "\n" ;end end end);local v154,v155=pcall(function() return v44(v152);end);local v156=v154 and v155 ;v153=v153   .. "\n🎯 Статус фарма: "   .. ((v156 and "✅ ВАЛИДНЫЙ") or "❌ НЕВАЛИДНЫЙ") ;v84:Set({Title="🎯 Информация: "   .. v152.Name ,Content=v153});end});local v86=v14:CreateSection("Системная информация");local v87=v14:CreateParagraph({Title="🖥️ Системная информация",Content="Нажмите 'Обновить' для получения информации"});local v88=v14:CreateButton({Name="💻 Обновить системную информацию",Callback=function() local v157="🎯 Основное:\n";v157=v157   .. "• Игрок: "   .. v6.Name   .. "\n" ;v157=v157   .. "• FPS: "   .. tostring(math.floor(1/v2.RenderStepped:Wait() ))   .. "\n" ;v157=v157   .. "• Время игры: "   .. tostring(math.floor(game:GetService("Workspace").DistributedGameTime))   .. "с\n\n" ;v157=v157   .. "🔧 Фарм:\n" ;v157=v157   .. "• Объектов в списке: "   ..  #v16   .. "\n" ;v157=v157   .. "• Авто-фарм: "   .. ((v18 and "✅ ВКЛ") or "❌ ВЫКЛ")   .. "\n" ;v157=v157   .. "• Текущий индекс: "   .. v17   .. "\n" ;v157=v157   .. "• Задержка: "   .. v19   .. "с\n" ;v157=v157   .. "• Длительность E: "   .. v20   .. "с\n" ;v157=v157   .. "• Noclip: "   .. ((v28 and "✅ ВКЛ") or "❌ ВЫКЛ")   .. "\n" ;v157=v157   .. "• Безопасная позиция: "   .. tostring(v31)   .. "\n\n" ;v157=v157   .. "👁️ Визуальные настройки:\n" ;v157=v157   .. "• ESP: "   .. ((v21 and "✅ ВКЛ") or "❌ ВЫКЛ")   .. "\n" ;v157=v157   .. "• FullBright: "   .. ((v24 and "✅ ВКЛ") or "❌ ВЫКЛ")   .. "\n" ;v157=v157   .. "• Скорость: "   .. v23   .. "\n" ;v87:Set({Title="🖥️ Системная информация",Content=v157});end});local function v89() if (v1:IsKeyDown(Enum.KeyCode.LeftShift) or v1:IsKeyDown(Enum.KeyCode.RightShift)) then local v213=v7.Target;if v213 then v15=v213;v53:Set("Объект: "   .. v213.Name );v54:Set("Класс: "   .. v213.ClassName );v55:Set("ID: "   .. tostring(v213:GetDebugId()) );local v230,v231=pcall(function() return v44(v213);end);local v232=v230 and v231 ;v56:Set("Статус: "   .. ((v232 and "✅ Подходит для фарма") or "❌ Не подходит") );v9:Notify({Title="Объект выбран",Content=v213.Name   .. " - "   .. ((v232 and "Подходит для фарма") or "Не подходит для фарма") ,Duration=2});end end end v7.Button1Down:Connect(v89);v6.CharacterAdded:Connect(function(v158) wait(1);v38();if v18 then wait(0.5);v36();end end);if v6.Character then v38();end spawn(function() while true do if v21 then v42();end wait(5);end end);spawn(function() while true do if v18 then v47();end wait(10);end end);v9:Notify({Title="🍬 Candy Farmer загружен",Content="Используйте Shift + ЛКМ по конфете для начала работы",Duration=6});print("🍬 Candy Farmer loaded! Use Shift + Click on candies to start farming.");
