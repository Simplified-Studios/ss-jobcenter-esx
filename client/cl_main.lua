Config = {
    Locations = {
        ["jobcenter"] = {
            coords = vector4(-269.19, -956.09, 31.22, 206.34),
            model = "s_m_m_armoured_01",
            blip = {
                sprite = 407,
                color = 4,
                scale = 0.7,
                label = "Job Center",
            },
        },
    }
}

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
    end
end)

CreateThread(function()
    while Config.Locations do
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