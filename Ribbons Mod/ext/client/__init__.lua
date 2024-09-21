-- Initialize the WebUI
WebUI:Init('Ribbons Mod')

-- Table to store active ribbons and their display duration
local activeRibbons = {}
local displayDuration = 5 -- Seconds to display each ribbon

-- Function to display a ribbon
function displayRibbon(ribbonName)
    -- Create a ribbon object with display details
    local ribbon = {
        name = ribbonName,
        startTime = SharedUtils:GetTime(), -- Current game time
        image = 'ui/Web/Ribbons/' .. ribbonName .. '.png' -- Ribbon image path
    }
    
    -- Add the ribbon to the active ribbons list
    table.insert(activeRibbons, ribbon)
end

-- Function to render the ribbon on the screen
function drawRibbon(ribbon)
    -- Get screen dimensions
    local screenWidth, screenHeight = ClientUtils:GetScreenSize()
    local ribbonWidth, ribbonHeight = 400, 100 -- Set ribbon size
    
    -- Calculate position to center the ribbon at the bottom of the screen
    local x = (screenWidth - ribbonWidth) / 2
    local y = screenHeight - 150 -- Display the ribbon 150 pixels from the bottom
    
    -- Draw the ribbon image at the calculated position
    DebugRenderer:DrawImage(ribbon.image, Vec2(x, y), Vec2(ribbonWidth, ribbonHeight), Vec4(1, 1, 1, 1))
end

-- Function to update and render all active ribbons
function updateRibbons(deltaTime)
    local currentTime = SharedUtils:GetTime()
    
    -- Iterate over active ribbons in reverse order to safely remove expired ones
    for i = #activeRibbons, 1, -1 do
        local ribbon = activeRibbons[i]
        
        -- Check if the ribbon's display duration has expired
        if (currentTime - ribbon.startTime) <= displayDuration then
            drawRibbon(ribbon)
        else
            -- Remove expired ribbons
            table.remove(activeRibbons, i)
        end
    end
end

-- Listen for the "DisplayRibbon" event from the server
NetEvents:Subscribe('DisplayRibbon', function(ribbonName)
    displayRibbon(ribbonName)
end)

-- Event handler for rendering the UI on screen
Events:Subscribe('UI:DrawHud', function(deltaTime)
    updateRibbons(deltaTime)
end)