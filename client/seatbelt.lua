SetFlyThroughWindscreenParams(Config.ejectVelocity, Config.unknownEjectVelocity, Config.unknownModifier, Config.minDamage);
local seatbeltOn = false
local ped = nil
local uiactive = false

CreateThread(function()
    while true do
        ped = PlayerPedId()
        Wait(500)
    end
end)

CreateThread(function()
    while true do
        Wait(50)
        if IsPedInAnyVehicle(ped, false) then
            if seatbeltOn then
                if Config.fixedWhileBuckled then
                    DisableControlAction(0, 75, true) -- Disable exit vehicle when stopped
                    DisableControlAction(27, 75, true) -- Disable exit vehicle when Driving
                end
                toggleUI(false)
            else
                toggleUI(true)
            end
        else
            if seatbeltOn then
                seatbeltOn = false
                toggleSeatbelt(false, false)
            end
            toggleUI(false)
            Wait(1000)
        end
    end
end)

function toggleSeatbelt(makeSound, toggle)
    if toggle == nil then
        if seatbeltOn then
            -- Show progress bar for unbuckling
            local finished = lib.progressCircle({
                duration = 2000,  -- 2 seconds duration for unbuckling
                label = 'Atsisegamas saugos diržas...',
                position = 'bottom', -- Position of the circle (can be 'bottom', 'middle', 'top')
                useWhileDead = false,
                canCancel = false,
                disable = { car = true, combat = true },
            })
            
            if finished then
                SetPedConfigFlag(PlayerPedId(), 32, false)
                SetFlyThroughWindscreenParams(Config.ejectVelocity, Config.unknownEjectVelocity, Config.unknownModifier, Config.minDamage)
                ESX.ShowNotification('Sėkmingai atsisegėte saugos diržą.')
                seatbeltOn = false
            end
        else
            -- Show progress bar for buckling
            local finished = lib.progressCircle({
                duration = 2000,  -- 2 seconds duration for buckling
                label = 'Užsisegamas saugos diržas...',
                position = 'bottom', -- Position of the circle (can be 'bottom', 'middle', 'top')
                useWhileDead = false,
                canCancel = false,
                disable = { car = true, combat = true },
            })

            if finished then
                --SetFlyThroughWindscreenParams(10000.0, 10000.0, 17.0, 500.0);
                SetFlyThroughWindscreenParams(15.6464, 2.2352, 0.0, 0.0)
                SetPedConfigFlag(PlayerPedId(), 32, true)
                ESX.ShowNotification('Sėkmingai užsisegėte saugos diržą.')
                seatbeltOn = true
            end
        end
    else
        if toggle then
            SetFlyThroughWindscreenParams(15.6464, 2.2352, 0.0, 0.0)
            SetPedConfigFlag(PlayerPedId(), 32, false)
        else
            SetPedConfigFlag(PlayerPedId(), 32, true)
            SetFlyThroughWindscreenParams(Config.ejectVelocity, Config.unknownEjectVelocity, Config.unknownModifier, Config.minDamage)
        end
        seatbeltOn = toggle
    end
end

function toggleUI(status)
    if Config.showUnbuckledIndicator then
        if uiactive ~= status then
            uiactive = status
            if status then
                SendNUIMessage({type = "set-belt", show = false})
            else
                SendNUIMessage({type = "set-belt", show = true})
            end
        end
    end
end

RegisterCommand('dirzas', function(source, args, rawCommand)
    if IsPedInAnyVehicle(ped, false) then
        local class = GetVehicleClass(GetVehiclePedIsIn(ped, false))
        if class ~= 8 and class ~= 13 and class ~= 14 then
            toggleSeatbelt(true)
        end
    end
end, false)

exports("status", function() return seatbeltOn end)

RegisterKeyMapping('dirzas', 'Užsisegti diržą.', 'keyboard', 'B')
