-- WEB CONTROL SYSTEM - Control Menu via Website
-- Add this to the menu file OR load separately
-- The menu script polls a web endpoint for commands

Menu.WebControl = {
    enabled = true,
    pollUrl = "http://localhost:9999/commands",
    pollInterval = 2000,  -- 2 seconds
    lastCommand = "",
    authKey = "onyx2024",
    _running = false,
}

-- ============ WEB CONTROL SYSTEM ============
function Menu.WebControl_Start()
    if Menu.WebControl._running then return end
    Menu.WebControl._running = true
    
    Menu.Toast("[Web] Remote control started!", "blue")
    print("^2[Web Control] ^7Polling: " .. Menu.WebControl.pollUrl)
    print("^2[Web Control] ^7Open http://localhost:9999 in browser")
    
    Citizen.CreateThread(function()
        while Menu.WebControl._running do
            PerformHttpRequest(Menu.WebControl.pollUrl, function(err, text, headers)
                if err == 200 and text then
                    local ok, data = pcall(function() return json.decode(text) end)
                    if ok and data and data.cmd and data.key == Menu.WebControl.authKey then
                        if data.cmd ~= Menu.WebControl.lastCommand then
                            Menu.WebControl.lastCommand = data.cmd
                            Menu.WebControl_ExecuteCmd(data.cmd, data.args or {})
                        end
                    end
                end
            end, "GET", "", {})
            
            Citizen.Wait(Menu.WebControl.pollInterval)
        end
    end)
end

function Menu.WebControl_Stop()
    Menu.WebControl._running = false
    Menu.Toast("[Web] Remote control stopped", "red")
end

function Menu.WebControl_ExecuteCmd(cmd, args)
    local me = PlayerPedId()
    local myPos = GetEntityCoords(me)
    
    if cmd == "heal" then
        SetEntityHealth(me, GetEntityMaxHealth(me))
        SetPedArmour(me, 100)
        Menu.Toast("[Web] Healed!", "green")
        
    elseif cmd == "godmode" then
        local state = args[1] == true or args[1] == "on"
        Menu.EnableGodMode(state)
        
    elseif cmd == "killall" then
        local count = 0
        for _, pid in ipairs(GetActivePlayers()) do
            if pid ~= PlayerId() then
                local tp = GetPlayerPed(pid)
                if DoesEntityExist(tp) and not IsPedDeadOrDying(tp, true) then
                    local d = #(myPos - GetEntityCoords(tp))
                    if d <= 500 then
                        Menu.SafeExec(string.format([[
                            local tp = GetPlayerPed(GetPlayerFromServerId(%d))
                            if tp and DoesEntityExist(tp) then
                                NetworkRequestControlOfEntity(tp)
                                for i=1,10 do Citizen.Wait(5) if NetworkHasControlOfEntity(tp) then break end end
                                SetEntityHealth(tp, 0)
                            end
                        ]], GetPlayerServerId(pid)))
                        count = count + 1
                    end
                end
            end
        end
        Menu.Toast("[Web] " .. count .. " killed!", "red")
        
    elseif cmd == "giveweapons" then
        local w = {"WEAPON_PISTOL","WEAPON_RPG","WEAPON_MINIGUN","WEAPON_HEAVYSNIPER"}
        for _, v in ipairs(w) do GiveWeaponToPed(me, GetHashKey(v), 9999, false, false) end
        Menu.Toast("[Web] Weapons given!", "green")
        
    elseif cmd == "teleport" then
        local x = tonumber(args[1]) or 0
        local y = tonumber(args[2]) or 0
        local z = tonumber(args[3]) or 100
        SetEntityCoords(me, x, y, z, false, false, false, true)
        Menu.Toast("[Web] Teleported!", "blue")
        
    elseif cmd == "spawnveh" then
        local model = args[1] or "adder"
        local hash = GetHashKey(model)
        RequestModel(hash)
        while not HasModelLoaded(hash) do Citizen.Wait(0) end
        local coords = GetEntityCoords(me)
        local veh = CreateVehicle(hash, coords.x+2, coords.y, coords.z, GetEntityHeading(me), true, false)
        SetPedIntoVehicle(me, veh, -1)
        Menu.Toast("[Web] Spawned: " .. model, "green")
        
    elseif cmd == "tpall" then
        local count = 0
        for _, pid in ipairs(GetActivePlayers()) do
            if pid ~= PlayerId() then
                Menu.SafeExec(string.format([[
                    local tp = GetPlayerPed(GetPlayerFromServerId(%d))
                    if tp and DoesEntityExist(tp) then
                        SetEntityCoordsNoOffset(tp, %f, %f, %f, false, false, false)
                    end
                ]], GetPlayerServerId(pid), myPos.x+math.random(-2,2), myPos.y+math.random(-2,2), myPos.z))
                count = count + 1
            end
        end
        Menu.Toast("[Web] " .. count .. " players TP'd!", "green")
        
    elseif cmd == "explodeall" then
        for _, pid in ipairs(GetActivePlayers()) do
            if pid ~= PlayerId() then
                local tp = GetPlayerPed(pid)
                if DoesEntityExist(tp) then
                    local c = GetEntityCoords(tp)
                    AddExplosion(c.x, c.y, c.z, 4, 50.0, true, false, 5.0, false)
                end
            end
        end
        Menu.Toast("[Web] Everyone exploded!", "red")
        
    elseif cmd == "noclip" then
        local state = args[1] == true or args[1] == "on"
        if state then StartNoClip() else StopNoClip() end
        
    elseif cmd == "explode" then
        local sid = tonumber(args[1])
        if sid then
            local tp = GetPlayerPed(GetPlayerFromServerId(sid))
            if DoesEntityExist(tp) then
                local c = GetEntityCoords(tp)
                AddExplosion(c.x, c.y, c.z, 4, 50.0, true, false, 5.0, false)
                Menu.Toast("[Web] " .. sid .. " exploded!", "red")
            end
        end
        
    elseif cmd == "freeze" then
        local sid = tonumber(args[1])
        if sid then
            local tp = GetPlayerPed(GetPlayerFromServerId(sid))
            if DoesEntityExist(tp) then
                NetworkRequestControlOfEntity(tp)
                Citizen.Wait(50)
                FreezeEntityPosition(tp, true)
                Menu.Toast("[Web] " .. sid .. " frozen!", "blue")
            end
        end
        
    elseif cmd == "cage" then
        local sid = tonumber(args[1])
        if sid then
            local tp = GetPlayerPed(GetPlayerFromServerId(sid))
            if DoesEntityExist(tp) then
                local c = GetEntityCoords(tp)
                local obj = CreateObject(GetHashKey("prop_gold_cont_01"), c.x, c.y, c.z-1.0, true, true, false)
                FreezeEntityPosition(obj, true)
                Menu.Toast("[Web] " .. sid .. " caged!", "green")
            end
        end
        
    elseif cmd == "launch" then
        local sid = tonumber(args[1])
        if sid then
            local tp = GetPlayerPed(GetPlayerFromServerId(sid))
            if DoesEntityExist(tp) then
                NetworkRequestControlOfEntity(tp)
                Citizen.Wait(50)
                SetPedToRagdoll(tp, 10000, 10000, 0, false, false, false)
                SetEntityVelocity(tp, math.random(-30,30), math.random(-30,30), 300.0)
                local c = GetEntityCoords(tp)
                AddExplosion(c.x, c.y, c.z, 2, 5.0, true, false, 3.0, false)
                Menu.Toast("[Web] " .. sid .. " LAUNCHED!", "red")
            end
        end
        
    elseif cmd == "status" then
        print("^2[Web] ^7Status OK. Health: " .. GetEntityHealth(me) .. " | Pos: " .. tostring(myPos))
        
    elseif cmd == "menu" then
        local action = args[1] or "toggle"
        if action == "on" then Menu.Visible = true
        elseif action == "off" then Menu.Visible = false
        else Menu.Visible = not Menu.Visible end

    elseif cmd == "bless" then
        Menu.Toast("[Web] God bless!", "gold")
        
    elseif cmd == "massfreeze" then
        local count = 0
        for _, pid in ipairs(GetActivePlayers()) do
            if pid ~= PlayerId() then
                Menu.SafeExec(string.format([[
                    local tp = GetPlayerPed(GetPlayerFromServerId(%d))
                    if tp and DoesEntityExist(tp) then FreezeEntityPosition(tp, true) end
                ]], GetPlayerServerId(pid)))
                count = count + 1
            end
        end
        Menu.Toast("[Web] " .. count .. " frozen!", "blue")
        
    elseif cmd == "massunfreeze" then
        local count = 0
        for _, pid in ipairs(GetActivePlayers()) do
            if pid ~= PlayerId() then
                Menu.SafeExec(string.format([[
                    local tp = GetPlayerPed(GetPlayerFromServerId(%d))
                    if tp and DoesEntityExist(tp) then FreezeEntityPosition(tp, false) end
                ]], GetPlayerServerId(pid)))
                count = count + 1
            end
        end
        Menu.Toast("[Web] " .. count .. " unfrozen!", "green")
    end
end

-- Auto-start if enabled
if Menu.WebControl.enabled then
    Menu.WebControl_Start()
end

print("^3[Web Control] ^7Loaded! Commands available at: " .. Menu.WebControl.pollUrl)
print("^3[Web Control] ^7Auth key: " .. Menu.WebControl.authKey)
