local delgunActive = false
local pauseCars = false
local pausePeds = false

-- Delgun toggle event
RegisterNetEvent("delgun:toggle")
AddEventHandler("delgun:toggle", function()
    delgunActive = not delgunActive

    if delgunActive then
        PlaySoundFrontend(-1, "Enter_1st", "GTAO_FM_Events_Soundset", false)
    end

    SendNUIMessage({ type = "toggle", status = delgunActive })
end)

-- Delgun functionality: Delete aimed entity when shooting
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if delgunActive and IsPedShooting(PlayerPedId()) then
            local hit, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
            if hit and DoesEntityExist(entity) then
                SetEntityAsMissionEntity(entity, true, true)
                DeleteEntity(entity)
            end
        end
    end
end)

-- Preset locations for deletion
local locations = {
    sandy    = { coords = vector3(1877, 3683, 33), radius = 3500.0 },
    paleto   = { coords = vector3(-218, 6325, 31), radius = 3500.0 },
    losantos = { coords = vector3(-1600, -320, 50), radius = 3500.0 }
}

function ClearVehiclesInArea(coords, radius)
    local vehicles = GetGamePool("CVehicle")
    for _, veh in ipairs(vehicles) do
        local vehCoords = GetEntityCoords(veh)
        if Vdist(vehCoords.x, vehCoords.y, vehCoords.z, coords.x, coords.y, coords.z) < radius then
            DeleteEntity(veh)
        end
    end
end

function ClearPedsInArea(coords, radius)
    local peds = GetGamePool("CPed")
    for _, ped in ipairs(peds) do
        if not IsPedAPlayer(ped) then
            local pedCoords = GetEntityCoords(ped)
            if Vdist(pedCoords.x, pedCoords.y, pedCoords.z, coords.x, coords.y, coords.z) < radius then
                DeleteEntity(ped)
            end
        end
    end
end

function ClearObjectsInArea(coords, radius)
    local objects = GetGamePool("CObject")
    for _, obj in ipairs(objects) do
        local objCoords = GetEntityCoords(obj)
        if Vdist(objCoords.x, objCoords.y, objCoords.z, coords.x, coords.y, coords.z) < radius then
            DeleteEntity(obj)
        end
    end
end

function ClearEverythingInArea(coords, radius)
    ClearVehiclesInArea(coords, radius)
    ClearPedsInArea(coords, radius)
    ClearObjectsInArea(coords, radius)
end

-- Continuous clearing thread for paused entities (runs every tick)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if pauseCars or pausePeds then
            for key, loc in pairs(locations) do
                if pauseCars then
                    ClearVehiclesInArea(loc.coords, loc.radius)
                end
                if pausePeds then
                    ClearPedsInArea(loc.coords, loc.radius)
                end
            end
        end
    end
end)

-- NUI Callback for deletion menu actions
RegisterNUICallback("menuAction", function(data, cb)
    local action = data.action

    if action == "updatePause" then
        pauseCars = data.pauseCars or false
        pausePeds = data.pausePeds or false
        cb("ok")
        return
    end

    local location = data.location
    if action == "closeMenu" then
        SetNuiFocus(false, false)
        SendNUIMessage({ type = "menuToggle", status = false })
    elseif action and location then
        if location == "all" then
            for _, loc in pairs(locations) do
                if action == "clearEverything" then
                    if not pauseCars then ClearVehiclesInArea(loc.coords, loc.radius) end
                    if not pausePeds then ClearPedsInArea(loc.coords, loc.radius) end
                    ClearObjectsInArea(loc.coords, loc.radius)
                end
            end
        else
            local loc = locations[location]
            if loc then
                if action == "clearCars" and not pauseCars then
                    ClearVehiclesInArea(loc.coords, loc.radius)
                elseif action == "clearPeds" and not pausePeds then
                    ClearPedsInArea(loc.coords, loc.radius)
                elseif action == "clearEverything" then
                    if not pauseCars then ClearVehiclesInArea(loc.coords, loc.radius) end
                    if not pausePeds then ClearPedsInArea(loc.coords, loc.radius) end
                    ClearObjectsInArea(loc.coords, loc.radius)
                end
            end
        end
    end

    cb("ok")
end)

-- Toggle the deletion menu (delmenu)
local delmenuActive = false
RegisterNetEvent("delmenu:toggle")
AddEventHandler("delmenu:toggle", function()
    delmenuActive = not delmenuActive
    SetNuiFocus(delmenuActive, delmenuActive)
    SendNUIMessage({ type = "menuToggle", status = delmenuActive })
end)

-- Example spawning functions that respect the pause flags:
function spawnVehicle(model, coords)
    if pauseCars then
        print("Vehicle spawning is paused.")
        return nil
    end
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, 0.0, true, false)
    if vehicle then
        SetVehicleOnGroundProperly(vehicle)
    end
    return vehicle
end

function spawnPed(model, coords)
    if pausePeds then
        print("Ped spawning is paused.")
        return nil
    end
    local ped = CreatePed(4, model, coords.x, coords.y, coords.z, 0.0, true, false)
    return ped
end

-- Example usage:
-- local myVehicle = spawnVehicle(GetHashKey("adder"), vector3(0, 0, 72))
-- local myPed = spawnPed(GetHashKey("a_m_m_skater_01"), vector3(0, 0, 72))
