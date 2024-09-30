Utils = {}
local progress = false

Utils.GetMinimap = function()
    local minimap = {}
	local resX, resY = GetActiveScreenResolution()
	local aspectRatio = GetAspectRatio(false)
	local scaleX = 1/resX
	local scaleY = 1/resY
	local minimapRawX, minimapRawY
	SetScriptGfxAlign(string.byte('L'), string.byte('B'))
	minimapRawX, minimapRawY = GetScriptGfxPosition(-0.0045, 0.002 + (-0.188888))
	minimap.width = scaleX*(resX/(4*aspectRatio))
	minimap.height = scaleY*(resY/(5.674))
	ResetScriptGfxAlign()
	minimap.leftX = minimapRawX
	minimap.rightX = minimapRawX+minimap.width
	minimap.topY = minimapRawY
	minimap.bottomY = minimapRawY+minimap.height
	minimap.X = minimapRawX+(minimap.width/2)
	minimap.Y = minimapRawY+(minimap.height/2)
    -- print(minimap.Y, minimap.X)
	return {
        x = minimap.leftX+0.0045,
        y = minimap.topY,
        right_x = minimap.rightX,
        height = minimap.height,
        width = minimap.width,
    }
end

Utils.InitHud = function()
    local minimap = Utils.GetMinimap()
	SendNUIMessage({
		type = 'app-show',
		show = true
	})
	ESX.TriggerServerCallback('hud:getPlayers', function(a)
		Wait(100)
		SendNUIMessage({
			type = 'set-info',
			id = GetPlayerServerId(PlayerId()),
			players = a
		})
	end)
    SendNUIMessage({
        type = 'set-minimap',
        data = minimap
    })
	for i = 1, #(Config.RemoveHudCommonents) do
		if Config.RemoveHudCommonents[i] then
			SetHudComponentPosition(i, 999999.0, 999999.0)
		end
	end
end

Utils.ProgressBar = function(time, message)
	if progress then return end
	progress = true
	SendNUIMessage({
		type = 'start-progress',
		time = time,
		message = message
	})
	while progress do
		Wait(100)
	end
end

Utils.Notification = function(data)
	SendNUIMessage({
		type = 'show-notification',
		notify = {
			title = data.title or 'Title',
			description = data.description or 'Description',
			title_color = data.titleColor or nil,
			icon = data.icon or 'fa-solid fa-info',
			icon_color = data.iconColor or 'white',
			time = data.time or 4000
		}
	})
end


RegisterNUICallback('progressEnd', function(a,cb)
	progress = false
	cb(true)
end)

RegisterNetEvent('hud:showNotification', function(data)
	Utils.Notification(data)
end)

exports('showNotification', Utils.Notification)
exports('showProgress', Utils.ProgressBar)