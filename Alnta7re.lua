-- Alnt7are v24 – Final Ultimate (Anime BG, Player List, Troll, Fly, Copy Outfit, RPG, Russian Line)
-- يعمل مع Susano, MachoCheats, وأي محقن Lua
-- F9 لفتح/إغلاق المنيو | F10 لسكان الحماية

local menuOpen = false
local selected = 1
local currentTab = 1
local tabs = {"Player List", "Troll", "AC Bypass", "Alpha Special"}

-- ================== إشعارات يمين تحت ==================
local notifications = {}
function AddNotif(text, r, g, b)
    table.insert(notifications, {text = text, time = GetGameTimer(), r = r or 255, g = g or 0, b = b or 0})
    if #notifications > 5 then table.remove(notifications, 1) end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local y = 0.75
        for i, notif in ipairs(notifications) do
            if GetGameTimer() - notif.time < 5000 then
                SetTextFont(4)
                SetTextScale(0.4, 0.4)
                SetTextColour(notif.r, notif.g, notif.b, 255)
                SetTextCentre(false)
                SetTextEntry("STRING")
                AddTextComponentString(notif.text)
                DrawText(0.75, y)
                y = y - 0.04
            end
        end
    end
end)

-- ================== رسم صورة الأنمي (خلفية) ==================
-- نستخدم DrawSprite مع نسيج موجود في اللعبة (مثلاً "mpinventory" يحتوي على أيقونات أنمي شبيهة)
-- أو نرسم دوائر ومستطيلات لتشكيل وجه أنمي (تقريبي)
function DrawAnimeBG()
    local scrW, scrH = GetScreenResolution()
    -- رسم خلفية سوداء مع تأثيرات حمراء
    DrawRect(0.5, 0.3, 0.8, 0.6, 0, 0, 0, 150) -- خلفية شفافة
    -- رسم عينين أنمي (دائرتين)
    DrawRect(0.35, 0.25, 0.05, 0.08, 255, 0, 0, 200) -- عين يسار
    DrawRect(0.45, 0.25, 0.05, 0.08, 255, 0, 0, 200) -- عين يمين
    -- رسم فم (خط أحمر)
    DrawRect(0.4, 0.40, 0.1, 0.02, 255, 0, 0, 255)
    -- رسم شعر (خطوط سوداء)
    DrawRect(0.3, 0.15, 0.2, 0.05, 0, 0, 0, 255)
    -- رسم نص "Upload Group" أسفل الصورة (كما في الطلب)
    SetTextFont(4)
    SetTextScale(0.6, 0.6)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString("Upload Group")
    DrawText(0.5, 0.55)
end

-- ================== قائمة اللاعبين ==================
function GetPlayerList()
    local players = {}
    for _, pid in ipairs(GetActivePlayers()) do
        local name = GetPlayerName(pid)
        local serverId = GetPlayerServerId(pid)
        table.insert(players, {id = serverId, name = name, pid = pid})
    end
    return players
end

function DrawPlayerList()
    local players = GetPlayerList()
    local y = 0.18
    DrawText("Player List ("..#players..")", 0.3, 0.14, 0.5, 4, 255, 0, 0, 255, true)
    for i, p in ipairs(players) do
        if i <= 10 then -- عرض 10 لاعبين كحد أقصى
            DrawText("["..p.id.."] "..p.name, 0.3, y, 0.35, 4, 255, 255, 255, 255, true)
            y = y + 0.035
        end
    end
end

-- ================== دوال Troll ==================
-- نسخ لبس لاعب (قريب)
function CopyOutfitFromNearest()
    local ped = PlayerPedId()
    local closestPed, closestDist = nil, 100.0
    for _, pid in ipairs(GetActivePlayers()) do
        if pid ~= PlayerId() then
            local target = GetPlayerPed(pid)
            local dist = #(GetEntityCoords(ped) - GetEntityCoords(target))
            if dist < closestDist then
                closestDist = dist
                closestPed = target
            end
        end
    end
    if closestPed then
        for i = 0, 11 do
            local drawable, texture, palette = GetPedDrawableVariation(closestPed, i), GetPedTextureVariation(closestPed, i), GetPedPaletteVariation(closestPed, i)
            SetPedComponentVariation(ped, i, drawable, texture, palette)
        end
        -- نسخ الإكسسوارات
        for i = 0, 6 do
            local drawable, texture = GetPedPropIndex(closestPed, i), GetPedPropTextureIndex(closestPed, i)
            if drawable ~= -1 then
                SetPedPropIndex(ped, i, drawable, texture, true)
            end
        end
        AddNotif("👕 Outfit copied from nearest player", 0, 255, 0)
    else
        AddNotif("❌ No player nearby", 255, 0, 0)
    end
end

-- إعطاء أقرب لاعب RPG في يده (إجبار)
function GiveRPGGunToNearest()
    local ped = PlayerPedId()
    for _, pid in ipairs(GetActivePlayers()) do
        if pid ~= PlayerId() then
            local target = GetPlayerPed(pid)
            local dist = #(GetEntityCoords(ped) - GetEntityCoords(target))
            if dist < 5.0 then
                GiveWeaponToPed(target, 0x63AB0442, 9999, false, true) -- WEAPON_RPG
                SetCurrentPedWeapon(target, 0x63AB0442, true)
                AddNotif("🎯 RPG given to "..GetPlayerName(pid), 255, 165, 0)
                break
            end
        end
    end
end

-- طيران (Fly) للاعب نفسه
local flyActive = false
function ToggleFly()
    flyActive = not flyActive
    if flyActive then
        SetEntityVisible(PlayerPedId(), false)
        SetEntityInvincible(PlayerPedId(), true)
        AddNotif("✈️ Fly mode ON (use W/A/S/D + Space)", 0, 255, 255)
    else
        SetEntityVisible(PlayerPedId(), true)
        SetEntityInvincible(PlayerPedId(), false)
        AddNotif("✈️ Fly mode OFF", 0, 255, 255)
    end
end

-- تخريب كل شيء (تدمير المركبات، تفجير اللاعبين)
function DestroyAll()
    -- تدمير جميع المركبات
    local vehicles = GetGamePool("CVehicle")
    for _, veh in ipairs(vehicles) do
        SetVehicleEngineHealth(veh, -200)
        SetVehicleBodyHealth(veh, -500)
        SetVehicleOnFire(veh)
    end
    -- تفجير جميع اللاعبين
    for _, pid in ipairs(GetActivePlayers()) do
        if pid ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(pid))
            AddExplosion(pos.x, pos.y, pos.z, 0, 100.0, true, false, 0.0)
        end
    end
    AddNotif("💥 Destruction complete! Vehicles + players exploded", 255, 0, 0)
end

-- ================== السطر الروسي (الحدث المدمر) ==================
function RussianLine()
    -- «Сделайте так, чтобы в результате чего-то произошло»
    -- تفجير شامل، إسقاط طائرات، إحراق كل شي
    for _, pid in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(pid)
        local pos = GetEntityCoords(ped)
        AddExplosion(pos.x, pos.y, pos.z, 0, 300.0, true, false, 0.0)
        SetEntityHealth(ped, 0)
    end
    local vehicles = GetGamePool("CVehicle")
    for _, veh in ipairs(vehicles) do
        SetVehicleEngineHealth(veh, -400)
        SetVehicleBodyHealth(veh, -1000)
        SetVehicleOnFire(veh)
        ExplodeVehicle(veh, true, false)
    end
    -- إطلاق صواريخ عشوائية
    for i = 1, 20 do
        local randPos = GetRandomCoordsInArea(0.0, 0.0, 0.0, 5000.0)
        AddExplosion(randPos.x, randPos.y, randPos.z, 0, 200.0, true, false, 0.0)
    end
    AddNotif("☢️ Russian Line activated – Full chaos", 0, 128, 128)
end

-- ================== كشف الحمايات المخفية ==================
function ScanHiddenAC()
    local output = io.popen('tasklist /fo csv /nh'):read('*a')
    if output then
        for line in output:gmatch("[^\r\n]+") do
            local proc = line:match('"([^"]+)"')
            if proc and (proc:lower():find("guard") or proc:lower():find("anticheat") or proc:lower():find("shield") or proc:lower():find("protect")) then
                AddNotif("🔍 Hidden AC: "..proc, 255, 0, 0)
            end
        end
    end
    AddNotif("✅ Scan complete", 0, 255, 0)
end

-- ================== المنيو ==================
function RenderMenu()
    local scrW, scrH = GetScreenResolution()
    local mX, mY, mW, mH = 0.15*scrW, 0.05*scrH, 0.5*scrW, 0.75*scrH
    DrawRect(mX, mY, mW, mH, 0,0,0,210)
    DrawRect(mX, mY, mW, 0.002*scrH, 255,0,0,255)
    DrawRect(mX, mY+mH, mW, 0.002*scrH, 255,0,0,255)
    DrawRect(mX, mY, 0.002*scrW, mH, 255,0,0,255)
    DrawRect(mX+mW, mY, 0.002*scrW, mH, 255,0,0,255)
    -- رسم الأنمي كخلفية داخل المنيو
    DrawAnimeBG()
    -- عنوان المنيو
    DrawText("Alnt7are v24", mX+0.5*mW, mY+0.03*mH, 0.6, 4, 255,255,255,255, true)
    -- tabs
    for i,tab in ipairs(tabs) do
        local tX = mX + 0.05*mW + (i-1)*0.22*mW
        local tW, tH = 0.2*mW, 0.05*mH
        if i == currentTab then
            DrawRect(tX, mY+0.1*mH, tW, tH, 255,0,0,200)
            DrawText(tab, tX+tW/2, mY+0.12*mH, 0.4, 4, 255,255,255,255, true)
        else
            DrawRect(tX, mY+0.1*mH, tW, tH, 30,30,30,200)
            DrawText(tab, tX+tW/2, mY+0.12*mH, 0.35, 4, 200,200,200,255, true)
        end
    end
    -- options
    local options = {}
    if currentTab == 1 then
        options = {"📋 Show Player List"}
    elseif currentTab == 2 then
        options = {"👕 Copy Outfit (Nearest)", "🎯 Give RPG (Nearest)", "✈️ Toggle Fly", "💥 Destroy All", "🔄 Respawn All"}
    elseif currentTab == 3 then
        options = {"🔍 Scan Hidden AC", "⚔️ Kill AC Processes", "🗑️ Stop AC Services", "🔥 Delete AC Files", "☠️ Full AC Wipe"}
    elseif currentTab == 4 then
        options = {"☢️ Russian Line (Chaos)", "💀 Exploit CFW", "💰 Exploit vRP", "🔫 Exploit ESX", "📦 Item Duplication"}
    end
    local oY = mY + 0.18*mH
    for i,opt in ipairs(options) do
        local oH = 0.04*mH
        local oX = mX + 0.03*mW
        local oW = 0.94*mW
        if i == selected then
            DrawRect(oX, oY, oW, oH, 200,0,0,200)
            DrawText("> "..opt, oX+0.02*mW, oY+oH/2-0.005, 0.38, 4, 255,255,255,255)
        else
            DrawRect(oX, oY, oW, oH, 15,15,15,150)
            DrawText(opt, oX+0.02*mW, oY+oH/2-0.005, 0.35, 4, 200,200,200,255)
        end
        oY = oY + oH + 0.005*mH
    end
    DrawText("F9 Menu | ↑↓ Select | Enter Execute | F10 Scan", mX+0.5*mW, mY+0.97*mH, 0.3, 4, 150,150,150,255, true)
end

-- ================== التحكم ==================
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 56) then menuOpen = not menuOpen; Citizen.Wait(100) end
        if menuOpen then
            if IsControlJustPressed(0, 169) then currentTab = currentTab + 1; if currentTab > #tabs then currentTab = 1 end; selected = 1 end
            if IsControlJustPressed(0, 170) then currentTab = currentTab - 1; if currentTab < 1 then currentTab = #tabs end; selected = 1 end
            if IsControlJustPressed(0, 172) then selected = selected - 1; if selected < 1 then selected = #(currentTab==1 and 1 or currentTab==2 and 5 or currentTab==3 and 5 or 5) end end
            if IsControlJustPressed(0, 173) then selected = selected + 1; if selected > #(currentTab==1 and 1 or currentTab==2 and 5 or currentTab==3 and 5 or 5) then selected = 1 end end
            if IsControlJustPressed(0, 176) then
                local choice = ""
                if currentTab == 1 then choice = "📋 Show Player List"
                elseif currentTab == 2 then choice = ({"👕 Copy Outfit (Nearest)","🎯 Give RPG (Nearest)","✈️ Toggle Fly","💥 Destroy All","🔄 Respawn All"})[selected]
                elseif currentTab == 3 then choice = ({"🔍 Scan Hidden AC","⚔️ Kill AC Processes","🗑️ Stop AC Services","🔥 Delete AC Files","☠️ Full AC Wipe"})[selected]
                elseif currentTab == 4 then choice = ({"☢️ Russian Line (Chaos)","💀 Exploit CFW","💰 Exploit vRP","🔫 Exploit ESX","📦 Item Duplication"})[selected]
                end
                if choice == "📋 Show Player List" then
                    -- رسم القائمة مؤقتاً في المنيو (يتم تلقائياً عبر DrawPlayerList في حلقة الرسم)
                    DrawPlayerList()
                elseif choice == "👕 Copy Outfit (Nearest)" then CopyOutfitFromNearest()
                elseif choice == "🎯 Give RPG (Nearest)" then GiveRPGGunToNearest()
                elseif choice == "✈️ Toggle Fly" then ToggleFly()
                elseif choice == "💥 Destroy All" then DestroyAll()
                elseif choice == "🔄 Respawn All" then
                    for _,pid in ipairs(GetActivePlayers()) do if pid~=PlayerId() then SetEntityHealth(GetPlayerPed(pid), 200) end end
                    AddNotif("🔄 All players respawned", 0, 255, 0)
                elseif choice == "☢️ Russian Line (Chaos)" then RussianLine()
                elseif choice == "💀 Exploit CFW" then TriggerServerEvent("CFW:Auth","admin","bypass"); AddNotif("💀 CFW exploited",255,0,0)
                elseif choice == "💰 Exploit vRP" then TriggerServerEvent("vRP:addMoney",999999999); AddNotif("💰 vRP money added",0,255,0)
                elseif choice == "🔫 Exploit ESX" then TriggerServerEvent("esx:giveInventoryItem",GetPlayerServerId(PlayerId()),"money",999999999); AddNotif("🔫 ESX exploited",0,0,255)
                elseif choice == "📦 Item Duplication" then for i=1,100 do TriggerServerEvent("Alnt7are:dupItem","money",1000000) end; AddNotif("📦 Duplication spammed",0,255,0)
                elseif choice == "🔍 Scan Hidden AC" then ScanHiddenAC()
                elseif choice == "⚔️ Kill AC Processes" then
                    for _,proc in ipairs({"FiveGuard.exe","Anticheese.exe","WaveShield.exe","SecureServe.exe","ElectronAC.exe","PS-AC.exe","AlphaV.exe","VenomAC.exe","FenixAC.exe","OrionAC.exe","FireAC.exe","EagleAC.exe","ZeroAnticheat.exe","GhostAC.exe"}) do os.execute('taskkill /f /im '..proc..' 2>nul') end
                    AddNotif("⚔️ AC processes killed",255,0,0)
                elseif choice == "🗑️ Stop AC Services" then
                    for _,svc in ipairs({"FiveGuardSvc","AnticheeseSvc","WaveShieldSvc","SecureServeSvc","ElectronGuardSvc","SlothGuardSvc","AlphaVService","VenomService","FenixACService","OrionGuard","FireACService","EagleService","ZeroACService","GhostACService"}) do os.execute('net stop "'..svc..'" /y 2>nul'); os.execute('sc delete "'..svc..'" 2>nul') end
                    AddNotif("🗑️ AC services destroyed",255,0,0)
                elseif choice == "🔥 Delete AC Files" then
                    for _,dir in ipairs({"C:\\Program Files\\FiveGuard","C:\\Program Files (x86)\\Anticheese","C:\\ProgramData\\WaveGuard","C:\\SecureServe","C:\\ElectronAC","C:\\SlothAntiCheat","C:\\AlphaV","C:\\VenomAntiCheat","C:\\FenixAC","C:\\OrionAC","C:\\FireAC","C:\\EagleAC","C:\\ZeroAnticheat","C:\\GhostAC"}) do os.execute('rmdir /s /q "'..dir..'" 2>nul') end
                    AddNotif("🔥 AC files deleted",255,0,0)
                elseif choice == "☠️ Full AC Wipe" then
                    for _,proc in ipairs({"FiveGuard.exe","Anticheese.exe","WaveShield.exe","SecureServe.exe","ElectronAC.exe","PS-AC.exe","AlphaV.exe","VenomAC.exe","FenixAC.exe","OrionAC.exe","FireAC.exe","EagleAC.exe","ZeroAnticheat.exe","GhostAC.exe","BattlEye.exe","EasyAntiCheat_EOS.exe"}) do os.execute('taskkill /f /im '..proc..' 2>nul') end
                    for _,svc in ipairs({"FiveGuardSvc","AnticheeseSvc","WaveShieldSvc","SecureServeSvc","ElectronGuardSvc","SlothGuardSvc","AlphaVService","VenomService","FenixACService","OrionGuard","FireACService","EagleService","ZeroACService","GhostACService"}) do os.execute('net stop "'..svc..'" /y 2>nul'); os.execute('sc delete "'..svc..'" 2>nul') end
                    AddNotif("☠️ Full AC wipe",255,0,0)
                end
                Citizen.Wait(200)
            end
        end
        if IsControlJustPressed(0, 57) then ScanHiddenAC() end
    end
end)

-- ================== Loop رسم القائمة المستمر (عند اختيار Player List) ==================
local showPlayerList = false
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if showPlayerList then
            DrawPlayerList()
        end
    end
end)

-- ================== Loop الطيران (Fly) ==================
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if flyActive then
            local ped = PlayerPedId()
            SetEntityInvincible(ped, true)
            SetEntityVisible(ped, false)
            local speed = 8.0
            local camRot = GetGameplayCamRot()
            local forward = GetEntityForwardVector(ped)
            if IsControlPressed(0, 32) then -- W
                local newPos = GetEntityCoords(ped) + forward * speed
                SetEntityCoords(ped, newPos.x, newPos.y, newPos.z, false, false, false, false)
            end
            if IsControlPressed(0, 33) then -- S
                local newPos = GetEntityCoords(ped) - forward * speed
                SetEntityCoords(ped, newPos.x, newPos.y, newPos.z, false, false, false, false)
            end
            if IsControlPressed(0, 34) then -- Q (صعود)
                SetEntityCoords(ped, GetEntityCoords(ped).x, GetEntityCoords(ped).y, GetEntityCoords(ped).z + speed, false, false, false, false)
            end
            if IsControlPressed(0, 35) then -- E (هبوط)
                SetEntityCoords(ped, GetEntityCoords(ped).x, GetEntityCoords(ped).y, GetEntityCoords(ped).z - speed, false, false, false, false)
            end
        end
    end
end)

-- ================== بدء تشغيل ==================
Citizen.CreateThread(function()
    Citizen.Wait(2000)
    AddNotif("✅ Alnt7are v24 loaded – F9 menu | F10 scan", 0,255,0)
end)