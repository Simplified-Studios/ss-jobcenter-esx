RegisterNetEvent('ss-jobcenter:server:openJobCenter', function()
    local source = source
    TriggerClientEvent('ss-jobcenter:client:openJobCenter', source, Config)
end)

RegisterNetEvent('esx:playerLoaded', function(player, xPlayer, isNew)
    TriggerClientEvent('ss-jobcenter:client:setup', player, Config.Main)
end)

RegisterNetEvent('ss-jobcenter:server:startJob', function(job)
    local source = source
    local Player = ESX.GetPlayerFromId(source)

    local jobExists = false
    for k, v in pairs(Config.Jobs) do
        if v.rank == job then
            jobExists = true
        end
    end

    for k,v in pairs(Config.Main.Locations) do
        if #(GetEntityCoords(GetPlayerPed(source)) - vector3(v.coords.x, v.coords.y, v.coords.z)) < 10.0 then
            if jobExists then
                if ESX.DoesJobExist(job, 0) then 
                    Player.setJob(job, 0)
                    Player.showNotification('You have been hired as a '..job..'!')
                else
                    Player.showNotification('Job or Grade does not exsist in database!')
                end
            else
                Player.showNotification('This job does not exist!')
            end
        else
            Player.showNotification('You are not near the job center!')
        end
    end
end)