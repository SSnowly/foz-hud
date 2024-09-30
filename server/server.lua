ESX.RegisterServerCallback('hud:getPlayers', function(source, cb)
    local count = GetNumPlayerIndices()
    cb(count)
end)

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining then
        TriggerClientEvent('hud:showAnnoucment', -1, eventData.secondsRemaining)
    end
end)