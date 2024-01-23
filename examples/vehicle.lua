-- Currently, only ESX and QBCore are supported.
pk_advancedmenu = exports.pk_advancedmenu
pk_defaults = exports.pk_defaults
showVehicleOptions = true
vehicle, distance = nil, nil
frameworkType = nil
frameworkAPI = nil

Citizen.CreateThread(function()
    -- Check if the 'qb-core' resource is started
    local isQBCoreStarted = GetResourceState('qb-core') == "started"
    if isQBCoreStarted then
        frameworkType = 'qb' -- Set the framework type to 'qb'
        frameworkAPI = exports['qb-core']:GetCoreObject() -- Get the QB-Core framework object
        return
    end

    -- Check if the 'es_extended' resource is started
    local isESXStarted = GetResourceState('pk_core') == "started"
    if isESXStarted then
        frameworkType = 'esx' -- Set the framework type to 'esx'
        frameworkAPI = exports['pk_core']:getSharedObject() -- Get the ESX framework object
        return
    end

    -- Error message if neither QBCore nor ESX frameworks are detected
    error("Unsupported framework detected. Currently, only ESX and QBCore are supported.")
end)

-- Function to get the closest vehicle based on the active game framework
-- @returns The closest vehicle entity based on the framework used
function FindClosestVehicle()
    -- Check and retrieve closest vehicle based on the 'qb' framework
    if frameworkType == 'qb' then
        return frameworkAPI.Functions.GetClosestVehicle()
    -- Check and retrieve closest vehicle based on the 'esx' framework
    elseif frameworkType == 'esx' then
        return frameworkAPI.Game.GetClosestVehicle()
    end
end


Citizen.CreateThread(function()
    while frameworkType == nil do
        Citizen.Wait(25)
    end
	while true do
        vehicle, distance = FindClosestVehicle()
		if DoesEntityExist(vehicle) and distance <= 4.0 then
			if not IsPedInVehicle(PlayerPedId(), vehicle, true) then
				showVehicleOptions = true
				lockStatus = GetVehicleDoorLockStatus(vehicle)
				vehCoords = GetEntityCoords(vehicle)
			else
				showVehicleOptions = false
			end
		else
			showVehicleOptions = false
		end
		Citizen.Wait(250)
	end
end)

Citizen.CreateThread(function()
    while frameworkType == nil do
        Citizen.Wait(25)
    end

    local xPed, xPedCoords, bonePos, distanceToBone, isopen
    local vDistance = 2
    local parts = {
        ["handle_dside_f"] = {
            title="Handle",
            doorId=0
        },
        ["handle_pside_f"] = {
            title="Handle",
            doorId=1
        },
        ["handle_dside_r"] = {
            title="Handle",
            doorId=2
        },
        ["handle_pside_r"] = {
            title="Handle",
            doorId=3
        },
        ["bonnet"] = {
            title="Bonnet",
            doorId=4
        },
        ["boot"] = {
            title="Trunk",
            doorId=5
        }
    }

    local data = {}

    while true do
        Citizen.Wait(showVehicleOptions and 0 or 250)

        if showVehicleOptions and lockStatus == 1 then
            xPed = PlayerPedId()
            xPedCoords = GetEntityCoords(xPed)
            RequestControlOfEntity(vehicle)

            for partName, partData in pairs(parts) do
                bonePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, partName))
                distanceToBone = GetDistanceBetweenCoords(xPedCoords, bonePos)

                if distanceToBone < vDistance then
                    isopen = GetVehicleDoorAngleRatio(vehicle, partData.doorId)
                    local actionTitle = isopen == 0 and "Open" or "Close"

                    local menuOptions = {
                        {
                            title = actionTitle,
                            action = function()
                                if isopen == 0 then
                                    SetVehicleDoorOpen(vehicle, partData.doorId, false, false)
                                else
                                    SetVehicleDoorShut(vehicle, partData.doorId, false)
                                end
                            end
                        }
                    }

                    if partData.doorId < 4 then
                        table.insert(menuOptions, {
                            title = "Enter",
                            action = function()
                                TaskEnterVehicle(xPed, vehicle, 10000, partData.doorId - 1, 1.0, 1, 0)
                            end
                        })
                    end

                    data[partName] = pk_advancedmenu:CreateMenu({
                        title = partData.title,
                        options = menuOptions,
                        coords = {x = bonePos.x, y = bonePos.y, z = bonePos.z},
                        data = data[partName]
                    })
                end
            end
        end
    end
end)

-- Function to request control over an entity with a timeout
-- @param targetEntity: The entity over which control is requested
-- @param controlTimeout: Maximum time in milliseconds to attempt control (default 3000ms)
function RequestControlOfEntity(entity, timeout)
	local time = GetGameTimer()
	if timeout == nil then
		timeout = 3000
	end
	while NetworkHasControlOfEntity(entity) do
		NetworkRequestControlOfEntity(entity)
		if time + timeout > GetGameTimer() then
			goto TimeoutForEntityControlRequest
		end
		Wait(25)
	end
	::TimeoutForEntityControlRequest::
end
