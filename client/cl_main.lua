Config = {}
local zones = {}

RegisterNetEvent('ss-jobcenter:client:setup', function(cfg)
    Config = cfg
    for k, v in pairs(Config.Locations) do
        RequestModel(v.model)
        while not HasModelLoaded(v.model) do
            Wait(1)
        end
        local ped = CreatePed(4, v.model, v.coords.x, v.coords.y, v.coords.z - 1, v.coords.w, false, true)
        PlaceObjectOnGroundProperly(ped)
        SetEntityHeading(ped, v.coords.w)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetModelAsNoLongerNeeded(v.model)
        FreezeEntityPosition(ped, true)
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

        local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
        SetBlipSprite(blip, 407)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 0)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Job Center")
        EndTextCommandSetBlipName(blip)
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

RegisterNUICallback('select', function(data, cb)
    TriggerServerEvent('ss-jobcenter:server:select', data)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        TriggerServerEvent('ss-jobcenter:server:setup')
    end
end)