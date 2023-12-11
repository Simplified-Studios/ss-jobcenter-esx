Config = {}

RegisterNetEvent('ss-jobcenter:client:setup', function(cfg)
    Config = cfg

    for k, v in pairs(Config.Locations) do
        local blip = AddBlipForCoord(v.coords)
        SetBlipSprite(blip, v.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, v.blip.scale)
        SetBlipColour(blip, v.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.blip.label)
        EndTextCommandSetBlipName(blip)

        RequestModel(v.model)
        while not HasModelLoaded(v.model) do
            Wait(1)
        end
        ped = CreatePed(4, v.model, v.coords.x, v.coords.y, v.coords.z-1, v.coords.w, false, true)
        SetEntityHeading(ped, v.coords.w)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        if Config.useTarget then
            if not Config.targetSystem then
                print('You need to set a target system in the config if you want to use it.')
            elseif Config.targetSystem == 'ox_target' then
                exports.ox_target:addLocalEntity(ped,{
                    name = 'jobcenter_menu',
                    serverEvent = 'ss-jobcenter:server:openJobCenter',
                    icon = 'fa-solid fa-suitcase',
                    label = 'Open job center'
                })
            end
        end
    end
end)

CreateThread(function()
    while not Config.useTarget do
        local sleep = 1500
        local currentShop = nil
        for k, v in pairs(Config.Locations) do
            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)
            local dist = GetDistanceBetweenCoords(pedCoords, v.coords, true)
            if dist < 5.0 then
                sleep = 5
                ESX.ShowHelpNotification('Press ~INPUT_PICKUP~ to open the job center.')
                if IsControlJustPressed(0, 38) then
                    TriggerServerEvent('ss-jobcenter:server:openJobCenter')
                end
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('ss-jobcenter:client:openJobCenter', function(config)
    SendNUIMessage({
        type = 'open',
        config = config,
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback('startJob', function(data, cb)
    TriggerServerEvent('ss-jobcenter:server:startJob', data.rank)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)