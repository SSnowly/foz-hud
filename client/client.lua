local zones = json.decode('{"HAWICK":"Hawick","ELYSIAN":"Elysian Island","SANDY":"Sandy Shores","DESRT":"Grand Senora Desert","LEGSQU":"Legion Square","MTCHIL":"Mount Chiliad","PALMPOW":"Palmer-Taylor Power Station","CCREAK":"Cassidy Creek","PROL":"North Yankton","PBLUFF":"Pacific Bluffs","MIRR":"Mirror Park","RICHM":"Richman","ZQ_UAR":"Davis Quartz","EAST_V":"East Vinewood","LAGO":"Lago Zancudo","BRADT":"Braddock Tunnel","NCHU":"North Chumash","CYPRE":"Cypress Flats","GALFISH":"Galilee","ZP_ORT":"Port of South Los Santos","PALETO":"Paleto Bay","BURTON":"Burton","GRAPES":"Grapeseed","DELSOL":"La Puerta","ALAMO":"Alamo Sea","DELPE":"Del Perro","ARMYB":"Fort Zancudo","STAD":"Maze Bank Arena","MORN":"Morningwood","CANNY":"Raton Canyon","ISHeist":"Cayo Perico Island","TEXTI":"Textile City","ALTA":"Alta","DTVINE":"Downtown Vinewood","HARMO":"Harmony","MURRI":"Murrieta Heights","KOREAT":"Little Seoul","GALLI":"Galileo Park","DOWNT":"Downtown","ZANCUDO":"Zancudo River","WVINE":"West Vinewood","BAYTRE":"Baytree Canyon","WINDF":"Ron Alternates Wind Farm","VINE":"Vinewood","EBURO":"El Burro Heights","DAVIS":"Davis","STRAW":"Strawberry","TONGVAV":"Tongva Valley","PALHIGH":"Palomino Highlands","TONGVAH":"Tongva Hills","CALAFB":"Calafia Bridge","CHAMH":"Chamberlain Hills","PBOX":"Pillbox Hill","MTJOSE":"Mount Josiah","TERMINA":"Terminal","HUMLAB":"Humane Labs and Research","PALFOR":"Paleto Forest","PALCOV":"Paleto Cove","TATAMO":"Tataviam Mountains","LDAM":"Land Act Dam","MOVIE":"Richards Majestic","VCANA":"Vespucci Canals","HORS":"Vinewood Racetrack","SKID":"Mission Row","CHU":"Chumash","SANCHIA":"San Chianski Mountain Range","CHIL":"Vinewood Hills","ROCKF":"Rockford Hills","RTRAK":"Redwood Lights Track","RGLEN":"Richman Glen","CMSW":"Chiliad Mountain State Wilderness","PROCOB":"Procopio Beach","RANCHO":"Rancho","GREATC":"Great Chaparral","BRADP":"Braddock Pass","ELGORL":"El Gordo Lighthouse","VESP":"Vespucci","OCEANA":"Pacific Ocean","JAIL":"Bolingbroke Penitentiary","OBSERV":"Galileo Observatory","BEACH":"Vespucci Beach","BHAMCA":"Banham Canyon","GOLF":"GWC and Golfing Society","SLAB":"Stab City","LACT":"Land Act Reservoir","LMESA":"La Mesa","DELBE":"Del Perro Beach","BANNING":"Banning","MTGORDO":"Mount Gordo","LOSPUER":"La Puerta","NOOSE":"N.O.O.S.E","AIRP":"Los Santos International Airport"}')

PlayerData = {
    ped = nil,
    uiopen = false,
    loaded = false,
    inveh = false,
    seatbelt = false,
    lock = false,
    status = {},
    job = {}
}

RegisterNetEvent('esx:playerLoaded', function(playerData)
    Utils.InitHud()
    PlayerThread()
end)

AddEventHandler('esx_status:onTick', function(data)
    local ped = PlayerPedId()
    local _status = data
    for i=1, #_status, 1 do
        PlayerData.status[_status[i].name] = _status[i].percent
    end

    SendNUIMessage({
        type = 'update-status',
        stamina = math.ceil(100 - GetPlayerSprintStaminaRemaining(PlayerId())) or 100,
        thirst = PlayerData.status['thirst'],
        hunger = PlayerData.status['hunger'],
        health = GetEntityHealth(ped) - 100 < 1 and 0 or GetEntityHealth(ped) - 100 ,
        armor = GetPedArmour(ped)
    })

    if IsPauseMenuActive() and PlayerData.uiopen then
        SendNUIMessage({
            type = 'app-show',
            show = false
        })
        PlayerData.uiopen = false
    elseif not IsPauseMenuActive() and not PlayerData.uiopen then
        SendNUIMessage({
            type = 'app-show',
            show = true
        })
        PlayerData.uiopen = true
    end
end)

CreateThread(function()
    local lastCompassHeading = nil
    while true do
        local camRot = GetGameplayCamRot(0)
        local heading = string.format("%.0f", (360.0 - ((camRot.z + 360.0) % 360.0)))
        if heading == '360' then heading = '0' end
        if lastCompassHeading ~= heading then
            SendNUIMessage({type = "update-compass", heading = heading})
        end
        lastCompassHeading = heading
        Wait(20) -- recommended values 10-30
    end
end)

local veh = nil
local engineStarted = false -- Track engine status

lib.onCache('vehicle', function(value)
    if value and not veh then
        veh = value
        SendNUIMessage({
            type = 'show-vehicle',
            show = true
        })
        while veh do
            local coords = GetEntityCoords(veh)
            local zoneNameFull = zones[GetNameOfZone(coords.x, coords.y, coords.z)]
            local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
            local fuel = Entity(veh).state.fuel
            local speed = GetEntitySpeed(veh) * 3.6
            local off, low, high = GetVehicleLightsState(veh)
            local lightson = low == 1 or high == 1
            local gear = GetVehicleCurrentGear(veh)

            -- Check engine state and send the message only if it changes
            local engineOn = GetIsVehicleEngineRunning(veh)
            if engineOn ~= engineStarted then
                engineStarted = engineOn
                SendNUIMessage({
                    type = 'EngineStarted',
                    status = engineOn -- Send true/false to indicate engine state
                })
            end

            -- Send other vehicle data
            SendNUIMessage({
                type = 'update-vehicle',
                fuel = fuel,
                speed = speed,
                lights = lightson,
                gear = gear == 0 and 'N' or gear,
                location = {
                    name = zoneNameFull,
                    street = streetName
                }
            })

            Wait(150)
        end
        SendNUIMessage({
            type = 'show-vehicle',
            show = false
        })
    else
        veh = nil
    end
end)


-- Funkcija, kuri paleidžia arba sustabdo variklį su NUI progress bar'u
function ToggleEngine()
    local ped = PlayerPedId() -- Get the player's ped
    local veh = GetVehiclePedIsIn(ped, false) -- Get the vehicle the player is in
    if veh then
        local engineOn = GetIsVehicleEngineRunning(veh)
        local progressLabel = engineOn and 'Užgesinamas variklis...' or 'Užkuriamas variklis...'
        local progressTime = 3000 -- 3 seconds for the progress bar

        -- Use ox_lib's circular progress bar
        local success = lib.progressCircle({
            duration = progressTime,
            label = progressLabel,
            position = 'bottom', -- Position of the circle (can be 'bottom', 'middle', 'top')
            useWhileDead = false, -- Disable if the player is dead
            canCancel = false, -- Prevent canceling the progress bar
            disable = { car = true, combat = true }, -- Disable car control and combat
        })

        -- Once the progress bar completes, toggle the engine state
        if success then
            if engineOn then
                -- Turn off the engine
                SetVehicleEngineOn(veh, false, true, true)
                SetVehicleUndriveable(veh, true) -- Make the vehicle undriveable when the engine is off
            else
                -- Turn on the engine
                SetVehicleEngineOn(veh, true, true, false)
                SetVehicleUndriveable(veh, false) -- Make the vehicle driveable when the engine is on
            end

            -- Update the engine state
            engineStarted = not engineOn -- Toggle the engine status

            -- Send an NUI message to update the engine status UI if applicable
            SendNUIMessage({
                type = 'EngineStarted',
                status = not engineOn -- Sends true or false to update the engine status UI
            })
        end
    end
end

-- Bind the "G" key to toggle the engine on or off
RegisterKeyMapping('toggleengine', 'Toggle Engine', 'keyboard', 'g')

-- Register the command "toggleengine" to trigger the ToggleEngine function
RegisterCommand('toggleengine', function()
    ToggleEngine()
end, false)




CreateThread(function()
	if ESX.PlayerLoaded then
        Utils.InitHud()
        PlayerThread()
    end
end)

function PlayerThread()
    CreateThread(function()
        while true do
            ESX.TriggerServerCallback('hud:getPlayers', function(a)
                SendNUIMessage({
                    type = 'update-info',
                    players = a
                })
            end)
            SetBlipAlpha(GetNorthRadarBlip(), 0)
            Wait(10000)
        end
    end)
end

local hud = true
RegisterCommand('hud', function()
    hud = not hud
    SendNUIMessage({
        type = 'app-show',
        show = hud
    })
    if hud then
        local minimap = Utils.GetMinimap()
        SendNUIMessage({
            type = 'set-minimap',
            data = minimap
        })
    end
end, false)

RegisterNetEvent('hud:showAnnoucment', function(seconds)
    SendNUIMessage({
        type = 'update-annoucment',
        seconds = seconds
    })
end)