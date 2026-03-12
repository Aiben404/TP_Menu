-- ═══════════════════════════════════════════════
--  SNOWMAN TP MENU — SERVER
-- ═══════════════════════════════════════════════

local ESX        = nil
local tpHistory  = {}  -- server-side history for admin panel

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

-- ─────────────────────────────────────────────
--  LOG TELEPORT
-- ─────────────────────────────────────────────

RegisterNetEvent('snowman_tpmenu:log')
AddEventHandler('snowman_tpmenu:log', function(locationName, x, y, z)
    local src     = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local entry = {
        playerName = GetPlayerName(src),
        identifier = xPlayer.identifier,
        location   = locationName,
        coords     = string.format('%.1f, %.1f, %.1f', x, y, z),
        time       = os.date('%Y-%m-%d %H:%M:%S'),
    }

    table.insert(tpHistory, 1, entry)
    if #tpHistory > (Config.Features.HistoryMaxEntries or 50) then
        table.remove(tpHistory)
    end

    if Config.LogTeleports then
        print(string.format(
            '[Snowman-TPMenu] %s (%s) → "%s" [%s]',
            entry.playerName, entry.identifier, entry.location, entry.coords
        ))
    end
end)

-- ─────────────────────────────────────────────
--  MONEY CHARGE
-- ─────────────────────────────────────────────

RegisterNetEvent('snowman_tpmenu:chargeMoney')
AddEventHandler('snowman_tpmenu:chargeMoney', function(locationId, cost)
    local src     = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    -- Find location in config
    local loc = nil
    for _, l in ipairs(Config.Locations) do
        if l.id == locationId then loc = l break end
    end
    if not loc then return end

    -- Validate cost server-side
    local account = Config.Features.CostAccount or 'money'
    local balance = xPlayer.getAccount(account).money

    if balance < cost then
        TriggerClientEvent('snowman_tpmenu:chargeResult', src, locationId, false,
            'Not enough ' .. account .. '. Need $' .. cost)
        return
    end

    xPlayer.removeAccountMoney(account, cost)
    TriggerClientEvent('snowman_tpmenu:chargeResult', src, locationId, true, nil)
end)

-- ─────────────────────────────────────────────
--  WHITELIST CHECK (server-side security)
-- ─────────────────────────────────────────────

RegisterNetEvent('snowman_tpmenu:checkWhitelist')
AddEventHandler('snowman_tpmenu:checkWhitelist', function(locationId)
    local src     = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if not Config.Features.Whitelist then
        TriggerClientEvent('snowman_tpmenu:whitelistResult', src, locationId, true)
        return
    end

    local loc = nil
    for _, l in ipairs(Config.Locations) do
        if l.id == locationId then loc = l break end
    end

    if not loc or not loc.whitelist or #loc.whitelist == 0 then
        TriggerClientEvent('snowman_tpmenu:whitelistResult', src, locationId, true)
        return
    end

    local identifier = xPlayer.identifier
    local allowed    = false
    for _, id in ipairs(loc.whitelist) do
        if identifier == id then allowed = true break end
    end

    -- Also check all identifiers (Discord, license, etc.)
    if not allowed then
        for i = 0, GetNumPlayerIdentifiers(src) - 1 do
            local ident = GetPlayerIdentifier(src, i)
            for _, id in ipairs(loc.whitelist) do
                if ident == id then allowed = true break end
            end
            if allowed then break end
        end
    end

    TriggerClientEvent('snowman_tpmenu:whitelistResult', src, locationId, allowed)
end)



-- Send TP history to admin
RegisterNetEvent('snowman_tpmenu:requestHistory')
AddEventHandler('snowman_tpmenu:requestHistory', function()
    local src     = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if xPlayer.getGroup() ~= Config.AdminGroup then return end
    TriggerClientEvent('snowman_tpmenu:historyData', src, tpHistory)
end)
