pk_advancedmenu = exports.pk_advancedmenu

menuData = nil
Citizen.CreateThread(function()
    local sleep = 250
	while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - vector3(-661.0857, -1644.2106, 25.1675))

        if distance <= 2.5 then
            sleep = 0
        else
            sleep = 250
        end

        menuData = pk_advancedmenu:CreateMenu({
            title = "Example Menu",
            options = {
                {
                    title = "Option 1",
                    action = function()
                        print("Option 1 selected")
                    end
                },
                {
                    title = "Option 2",
                    action = function()
                        print("Option 2 selected")
                    end
                },
                {
                    title = "Option 3",
                    action = function()
                        print("Option 3 selected")
                    end
                },
            },
            coords = {x = -661.0857, y = -1644.2106, z = 25.1675},
            data = menuData
        })
		Citizen.Wait(sleep)
	end
end)