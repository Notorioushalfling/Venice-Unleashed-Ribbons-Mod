-- Initialize a table to hold player stats
local playerStats = {}

-- Define the ribbon requirements and their image paths
local ribbons = {
    AssaultRifleRibbon = { xp = 1000, kills = 10, imagePath = "WebUI/Ribbons/AssaultRifleRibbon.png" },
    MarksmanRibbon = { xp = 800, headshots = 5, imagePath = "WebUI/Ribbons/MarksmanRibbon.png" },
    AntiVehicleRibbon = { xp = 150, vehiclesDestroyed = 3, imagePath = "WebUI/Ribbons/AntiVehicleRibbon.png" },
    ResupplyRibbon = { xp = 500, resupplies = 7, imagePath = "WebUI/Ribbons/ResupplyRibbon.png" },
    RepairRibbon = { xp = 600, repairs = 5, imagePath = "WebUI/Ribbons/RepairRibbon.png" }
}

-- Function to initialize player stats
function initializePlayerStats(player)
    playerStats[player.id] = {
        xp = 0,
        kills = 0,
        headshots = 0,
        vehiclesDestroyed = 0,
        resupplies = 0,
        repairs = 0
    }
    print("Initialized stats for player: " .. player.name)
end

-- Function to update player stats
function updatePlayerStats(player, stat, amount)
    if not playerStats[player.id] then
        initializePlayerStats(player)
    end
    playerStats[player.id][stat] = playerStats[player.id][stat] + amount
    print("Updated " .. stat .. " for player: " .. player.name .. " by " .. amount .. ". Total: " .. playerStats[player.id][stat])
    checkRibbons(player)
end

-- Function to reset player stats on disconnect
function resetPlayerStats(player)
    playerStats[player.id] = nil
    print("Reset stats for player: " .. player.name)
end

-- Function to check if a player meets the requirements for a ribbon
function checkRibbons(player)
    local stats = playerStats[player.id]
    if not stats then return end

    for ribbon, reqs in pairs(ribbons) do
        local meetsRequirements = true

        for stat, value in pairs(reqs) do
            if stat ~= "imagePath" and stats[stat] < value then
                meetsRequirements = false
                break
            end
        end

        if meetsRequirements then
            displayRibbon(player, ribbon)
        end
    end
end

-- Function to display the ribbon
function displayRibbon(player, ribbon)
    if WebUI then
        local imagePath = ribbons[ribbon].imagePath
        WebUI:call("showRibbon", { ribbon = ribbon, imagePath = imagePath })
        print("Displayed ribbon: " .. ribbon .. " for player: " .. player.name)
    else
        print("[Error] WebUI is not initialized!")
    end
end

-- Initialize the WebUI
Events:Subscribe('Engine:LoadComplete', function()
    WebUI:Init("WebUI/index.html")
    print("WebUI initialized with path 'WebUI/index.html'")
end)

-- Event to initialize stats when a player joins
Events:Subscribe('Player:Authenticated', function(player)
    initializePlayerStats(player)
    print("Player authenticated: " .. player.name)
end)

-- Event to reset stats when a player leaves
Events:Subscribe('Player:Left', function(player)
    resetPlayerStats(player)
    print("Player left: " .. player.name)
end)

-- Event to track player kills (including bots)
Events:Subscribe('Player:Killed', function(player, killer, weapon)
    if killer and type(killer) == "userdata" and not killer:IsBot() and killer:IsAlive() then
        if player and type(player) == "userdata" and not player:IsBot() and killer.id ~= player.id then
            updatePlayerStats(killer, 'kills', 1)
            updatePlayerStats(killer, 'xp', 100)
            print("Player killed: " .. player.name .. " by " .. killer.name)

            if weapon and weapon:IsValid() and weapon:IsSoldierWeapon() then
                local weaponType = weapon.weaponType
                if weaponType == 1 then
                    updatePlayerStats(killer, 'xp', 50)
                    print("Assault rifle bonus XP awarded to: " .. killer.name)
                end
            end
        elseif player and player:IsBot() then
            print("Bot killed: " .. player.name .. " by " .. killer.name)
        end
    else
        print("[Error] Invalid killer object: " .. tostring(killer))
    end
end)

-- Event to track headshots
Events:Subscribe('Player:Headshot', function(player, killer)
    if killer and type(killer) == "userdata" and not killer:IsBot() and killer:IsAlive() then
        updatePlayerStats(killer, 'headshots', 1)
        updatePlayerStats(killer, 'xp', 200)
        print("Headshot registered: " .. player.name .. " by " .. killer.name)
    end
end)

-- Event to track vehicle destruction
Events:Subscribe('Vehicle:Destroyed', function(vehicle, killer)
    if killer and type(killer) == "userdata" and not killer:IsBot() and killer:IsAlive() then
        updatePlayerStats(killer, 'vehiclesDestroyed', 1)
        updatePlayerStats(killer, 'xp', 300)
        print("Vehicle destroyed by: " .. killer.name)
    end
end)

-- Event to track resupplies
Events:Subscribe('Player:Resupply', function(player, supplier)
    if supplier and type(supplier) == "userdata" and not supplier:IsBot() and supplier:IsAlive() then
        updatePlayerStats(supplier, 'resupplies', 1)
        updatePlayerStats(supplier, 'xp', 50)
        print("Resupply done by: " .. supplier.name)
    end
end)

-- Event to track repairs
Events:Subscribe('Player:Repair', function(player, repairer)
    if repairer and type(repairer) == "userdata" and not repairer:IsBot() and repairer:IsAlive() then
        updatePlayerStats(repairer, 'repairs', 1)
        updatePlayerStats(repairer, 'xp', 75)
        print("Repair performed by: " .. repairer.name)
    end
end)

-- Event Test
Events:Subscribe('Player:Score', function(player, scoringTypeData, score)
    print("A SCORING EVENT HAS OCCURRED!!!!")
end)