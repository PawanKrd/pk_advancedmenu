-- Function to create and display a 3D menu
-- @param menuConfig: Configuration for the menu
function Create3DMenu(menuConfig)
    local isPlayerAimingAtMenu = false

    -- Initialize menu configuration with default values
    menuConfig.data = menuConfig.data or { selected = 1 }
    if menuConfig.data.selected == nil then
        menuConfig.data.selected = 1
    end
    menuConfig.font = menuConfig.font or 4

    -- Ensure the current selection is valid
    if not menuConfig.options[menuConfig.data.selected] or menuConfig.options[menuConfig.data.selected].disabled then
        menuConfig.data.selected = FindNextEnabledOptionId(menuConfig.options, 1)
    end

    -- Calculate the screen position for the menu
    local isOnScreen, screenPosX, screenPosY = GetScreenCoordFromWorldCoord(menuConfig.coords.x, menuConfig.coords.y, menuConfig.coords.z)
    local xDistanceFromCenter = math.abs(screenPosX - 0.5)
    local yDistanceFromCenter = screenPosY - 0.5
    local menuVerticalRange = (#menuConfig.options * 0.01) + 0.02

    -- Check if the player is aiming at the menu
    if xDistanceFromCenter < 0.03 and yDistanceFromCenter > -menuVerticalRange and screenPosY < 0.54 then
        isPlayerAimingAtMenu = true
        HandleMenuControls(menuConfig)
    end

    -- Assemble and draw the menu text
    local fullMenuText = GenerateFullMenuText(menuConfig, isPlayerAimingAtMenu)

    -- Get Distance to the menu
    local distanceToMenu = GetDistanceBetweenCoords(menuConfig.coords.x, menuConfig.coords.y, menuConfig.coords.z, GetEntityCoords(PlayerPedId()))

    if distanceToMenu > 2.5 then return end
    Draw3DText(menuConfig.coords.x, menuConfig.coords.y, menuConfig.coords.z, fullMenuText, { red = 255, green = 199, blue = 43, alpha = 180 }, menuConfig.font, menuConfig.scale)

    return menuConfig.data
end


-- Function to handle controls for a menu
-- @param menu: The menu to which the controls are applied
function HandleMenuControls(menu)
    -- Disable specific player controls when interacting with the menu
    local controlsToDisable = {261, 262, 300, 299, 38}
    for _, control in ipairs(controlsToDisable) do
        DisableControlAction(0, control, true)
    end
    ShowHudComponentThisFrame(14)  -- HUD component for menu interaction

    -- Process navigation inputs for the menu
    ProcessMenuNavigationInputs(menu)

    -- Execute action if a menu option is selected
    if IsMenuOptionSelected() then
        if IsPlayerEligibleForAction() then
            ExecuteSelectedOptionAction(menu)
        end
    end

    -- Prevent player from firing while interacting with the menu
    DisablePlayerFiring(PlayerId(), true)
end

-- Function to check if a menu option is selected based on input controls
-- @returns Boolean indicating if the menu option is selected
function IsMenuOptionSelected()
    -- Define the controls to check
    local controlsToCheck = {38, 24, 18} -- Control IDs for menu option selection

    for _, control in ipairs(controlsToCheck) do
        if IsControlJustReleased(0, control) or IsDisabledControlJustReleased(0, control) then
            return true
        end
    end

    return false
end

-- Function to check if the player is eligible to perform an action
-- @returns Boolean indicating whether the player can perform the action
function IsPlayerEligibleForAction()
	-- Get the player's current state
    local playerState = LocalPlayer.state
    -- Determine player's current state and vehicle status
    local isPlayerDead = playerState.dead
    local isInventoryOpen = playerState.invOpen
    local isPlayerInVehicle = IsPedInAnyVehicle(PlayerPedId(), true)

    -- Player is eligible if not dead, inventory is closed, and not in a vehicle
    return not (isPlayerDead or isInventoryOpen or isPlayerInVehicle)
end

-- Function to process navigation inputs for a menu
-- @param menu: The menu object to navigate
function ProcessMenuNavigationInputs(menu)
    -- Control codes for navigation
    local previousControlCodes = {261, 300, 27}
    local nextControlCodes = {262, 299, 173}

    -- Check and process 'previous' navigation input
    for _, control in ipairs(previousControlCodes) do
        if IsDisabledControlJustReleased(0, control) then
            menu.data.selected = FindPreviousEnabledOptionId(menu.options, menu.data.selected) or 1
            break -- Exit the loop once a control input is detected and processed
        end
    end

    -- Check and process 'next' navigation input
    for _, control in ipairs(nextControlCodes) do
        if IsDisabledControlJustReleased(0, control) then
            menu.data.selected = FindNextEnabledOptionId(menu.options, menu.data.selected) or #menu.options
            break -- Exit the loop once a control input is detected and processed
        end
    end
end


-- Function to execute the action of the selected menu option
-- @param menu: The menu containing options and their actions
function ExecuteSelectedOptionAction(menu)
    local selectedOption = menu.options[menu.data.selected]

    -- Check if the selected option exists and is enabled
    if selectedOption and not selectedOption.disabled then
        -- Execute the action associated with the selected option
        selectedOption.action()
    else
        -- Reset to the first option if the selected option is disabled or doesn't exist
        menu.data.selected = 1
    end
end


-- Function to generate text for all options in a menu
-- @param menuObject: The menu object containing options and configuration
-- @param isPlayerAimingAtMenu: Boolean indicating if the player is aiming at the menu
-- @returns A string representing the full menu text, including all options
function GenerateFullMenuText(menuObject, isPlayerAimingAtMenu)
    local fullMenuText = {}
    
    -- Iterate through each menu option to generate its text
    for optionIndex, menuOption in ipairs(menuObject.options) do
        local isOptionSelected = menuObject.data.selected == optionIndex
        local optionText = DrawMenuOption(menuOption, menuObject.coords, isOptionSelected, menuObject.font, isPlayerAimingAtMenu, menuObject.scale)

        if optionText then
            table.insert(fullMenuText, optionText)
        end
    end

    -- Concatenate the menu title and all option texts
    return menuObject.title .. "\n" .. table.concat(fullMenuText, "\n")
end


-- Function to draw an individual option of the 3D text menu
-- @param menuOption: The menu option to be drawn
-- @param optionCoords: The world coordinates for the option
-- @param isOptionSelected: Boolean indicating if the option is currently selected
-- @param optionFont: The font to be used for the option text
-- @param isPlayerAimingAtOption: Boolean indicating if the player is aiming at the option
-- @param optionScale: The scale to be used for the option text
function DrawMenuOption(menuOption, optionCoords, isOptionSelected, optionFont, isPlayerAimingAtOption, optionScale)
    local optionTitle = menuOption.title

    -- Modify the option title based on its state (selected, aimed, disabled)
    if isOptionSelected and isPlayerAimingAtOption and not menuOption.disabled then
        -- Highlight the selected and aimed option
        optionTitle = "~g~[E] " .. optionTitle
    else
        -- Apply a different style for non-selected or non-aimed options
        optionTitle = "~c~" .. optionTitle
    end

    -- Only return the option title if the option is not disabled
    if not menuOption.disabled then
        return optionTitle
    end

    return false
end
	

-- Function to find the next enabled option ID in a menu
-- @param menuOptions: The list of options in the menu
-- @param currentSelectionId: The ID of the currently selected menu option
-- @returns The ID of the next enabled option or 0 if none found
function FindNextEnabledOptionId(menuOptions, currentSelectionId)
    currentSelectionId = currentSelectionId or 1

    for optionId = currentSelectionId, #menuOptions do
        if optionId == #menuOptions then
            return #menuOptions
        end
        local isOptionEnabled = menuOptions[optionId]?.disabled == nil or menuOptions[optionId]?.disabled == false
        local isDifferentOption = optionId ~= currentSelectionId

        if isOptionEnabled and isDifferentOption then
            return optionId
        end
    end

    return 1
end


-- Function to find the previous enabled option ID in a menu
-- @param menuOptions: The list of options in the menu
-- @param currentSelectionId: The ID of the currently selected menu option
-- @returns The ID of the previous enabled option or 0 if none found
function FindPreviousEnabledOptionId(menuOptions, currentSelectionId)
    currentSelectionId = currentSelectionId or 1

    for optionId = currentSelectionId, 1, -1 do
        if optionId == 1 then
            return 1
        end
        local isOptionEnabled = menuOptions[optionId].disabled == nil or menuOptions[optionId].disabled == false
        local isDifferentOption = optionId ~= currentSelectionId

        if isOptionEnabled and isDifferentOption then
            return optionId
        end
    end

    return 0 -- Return 0 if no enabled option is found
end

-- Function to draw 3D text at a specified world coordinate
-- @param worldX, worldY, worldZ: World coordinates for the text
-- @param displayText: The text to display
-- @param textColor: Table containing RGBA values for text color (default if nil)
-- @param textFont: Text font (default if nil)
-- @param textSizeModifier: Additional scaling for the text (default if nil)
-- @param centerText: Boolean to center the text (true by default)
-- @param proportionalText: Boolean to make the text proportional (true by default)
function Draw3DText(worldX, worldY, worldZ, displayText, textColor, textFont, textSizeModifier, centerText, proportionalText)
    local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(worldX, worldY, worldZ)

    -- Return early if the text is not on screen
    if not onScreen then return end

    local baseScale = 0.30 -- Default text scale

    -- Set default values if parameters are not provided
    textColor = textColor or { red = 210, green = 210, blue = 210, alpha = 180 }
    textFont = textFont or 4
    textSizeModifier = textSizeModifier or 0
    centerText = centerText ~= false -- Default to true if not specified
    proportionalText = proportionalText ~= false -- Default to true if not specified

    -- Configure text properties
    SetTextFont(textFont)
    SetTextScale(baseScale + textSizeModifier, baseScale + textSizeModifier)
    SetTextProportional(proportionalText)
    SetTextColour(textColor.red, textColor.green, textColor.blue, textColor.alpha)
    SetTextCentre(centerText)
    SetTextDropshadow(50, 210, 210, 210, 255)
    SetTextOutline()

    -- Prepare and draw text
    SetTextEntry("STRING")
    AddTextComponentString(displayText)
    DrawText(screenX, screenY - 0.035) -- Adjust Y position for better alignment
end


exports('CreateMenu', Create3DMenu)
exports('Draw3DText', Draw3DText)