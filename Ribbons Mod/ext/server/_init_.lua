-- Initialize the WebUI
WebUI:Init('Ribbons Mod')

-- Initialize a table to hold player stats
local playerStats = {}

-- Define the ribbon requirements
local ribbons = {
    AssaultRifleRibbon = { xp = 1000, kills = 10 },
    MarksmanRibbon = { xp = 800, headshots = 5 },
    AntiVehicleRibbon = { xp = 1200, vehiclesDestroyed = 3 },
    ResupplyRibbon = { xp = 500, resupplies = 7 },
    RepairRibbon = { xp = 600, repairs = 5 }
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
end

-- Function to update player stats
function updatePlayerStats(player, stat, amount)
    if not playerStats[player.id] then
        initializePlayerStats(player)
    end
    playerStats[player.id][stat] = playerStats[player.id][stat] + amount
    checkRibbons(player)
end

-- Function to reset player stats on disconnect
function resetPlayerStats(player)
    playerStats[player.id] = nil
end

-- Function to check if a player meets the requirements for a ribbon
function checkRibbons(player)
    local stats = playerStats[player.id]
    if not stats then return end

    for ribbon, reqs in pairs(ribbons) do
        local meetsRequirements = true

        for stat, value in pairs(reqs) do
            if stats[stat] < value then
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
    -- Send to WebUI to display the ribbon
    WebUI:call("showRibbon", { ribbon = ribbon })
end

-- Event to initialize stats when a player joins
Events:Subscribe('Player:Authenticated', function(player)
    initializePlayerStats(player)
end)

-- Event to reset stats when a player leaves
Events:Subscribe('Player:Left', function(player)
    resetPlayerStats(player)
end)

-- Event to track player kills
Events:Subscribe('Player:Killed', function(player, killer, weapon)
    if killer and killer:IsAlive() and player and killer.id ~= player.id then
        updatePlayerStats(killer, 'kills', 1)
        updatePlayerStats(killer, 'xp', 100)

        if weapon and weapon:IsValid() and weapon:IsSoldierWeapon() then
            local weaponType = weapon.weaponType
            if weaponType == 1 then -- Assuming ID 1 is an example ID for assault rifles
                updatePlayerStats(killer, 'xp', 50) -- Bonus XP for using assault rifle
            end
        end
    end
end)

-- Event to track headshots
Events:Subscribe('Player:Headshot', function(player, killer)
    if killer and killer:IsAlive() then
        updatePlayerStats(killer, 'headshots', 1)
        updatePlayerStats(killer, 'xp', 200)
    end
end)

-- Event to track vehicle destruction
Events:Subscribe('Vehicle:Destroyed', function(vehicle, killer)
    if killer and killer:IsAlive() then
        updatePlayerStats(killer, 'vehiclesDestroyed', 1)
        updatePlayerStats(killer, 'xp', 300)
    end
end)

-- Event to track resupplies
Events:Subscribe('Player:Resupply', function(player, supplier)
    if supplier and supplier:IsAlive() then
        updatePlayerStats(supplier, 'resupplies', 1)
        updatePlayerStats(supplier, 'xp', 50)
    end
end)

-- Event to track repairs
Events:Subscribe('Player:Repair', function(player, repairer)
    if repairer and repairer:IsAlive() then
        updatePlayerStats(repairer, 'repairs', 1)
        updatePlayerStats(repairer, 'xp', 75)
    end
end)