-- ═══════════════════════════════════════════════
--  SNOWMAN TP MENU — CLIENT
-- ═══════════════════════════════════════════════

local ESX       = nil
local menuOpen  = false
local cooldowns = {}  -- [locationId] = gameTimer expiry
local tpHistory = {}  -- list of {name, time, coords}

-- ─────────────────────────────────────────────
--  ESX INIT
-- ─────────────────────────────────────────────

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

-- ─────────────────────────────────────────────
--  OX_LIB NOTIFY
-- ─────────────────────────────────────────────

local function Notify(msg, ntype)
    if not Config.Notify.enabled then return end
    lib.notify({
        title       = 'TP',
        description = msg,
        type        = ntype or Config.Notify.type,
        duration    = Config.Notify.duration,
        position    = Config.Notify.position,
    })
end

-- ─────────────────────────────────────────────
--  FEATURE HELPERS
-- ─────────────────────────────────────────────

local function IsFeatureOn(name)
    return Config.Features[name] == true
end

-- Get current hour using FiveM clock natives (os not available client-side)
local function GetServerHour()
    return GetClockHours()
end

-- Time-lock check: supports overnight ranges e.g. from=22 to=6
local function IsTimeAllowed(loc)
    if not IsFeatureOn('TimeLock') then return true end
    if not loc.hours then return true end
    local h    = GetServerHour()
    local from = loc.hours.from
    local to   = loc.hours.to
    if from <= to then
        return h >= from and h < to
    else
        return h >= from or h < to
    end
end

-- Cooldown check — returns onCooldown, secondsRemaining
local function IsOnCooldown(loc)
    if not IsFeatureOn('Cooldown') then return false, 0 end
    local cd = loc.cooldown ~= nil and loc.cooldown or Config.Features.DefaultCooldown
    if cd <= 0 then return false, 0 end
    local expiry = cooldowns[loc.id]
    if expiry and GetGameTimer() < expiry then
        return true, math.ceil((expiry - GetGameTimer()) / 1000)
    end
    return false, 0
end

local function SetCooldown(loc)
    if not IsFeatureOn('Cooldown') then return end
    local cd = loc.cooldown ~= nil and loc.cooldown or Config.Features.DefaultCooldown
    if cd <= 0 then return end
    cooldowns[loc.id] = GetGameTimer() + (cd * 1000)
end

-- ─────────────────────────────────────────────
--  PERMISSION CHECK — builds allowed list for UI
-- ─────────────────────────────────────────────

local function GetAllowedLocations()
    local playerData = ESX.GetPlayerData()
    local group      = playerData.group or 'user'
    local job        = playerData.job and playerData.job.name  or 'unemployed'
    local grade      = playerData.job and playerData.job.grade or 0

    local isAdmin = (group == Config.AdminGroup)
    local isVip   = (group == Config.VipGroup) or isAdmin

    local allowed = {}
    for _, loc in ipairs(Config.Locations) do
        local ok = true

        if loc.adminOnly and not isAdmin then ok = false end
        if loc.vipOnly   and not isVip   then ok = false end

        -- Job name check
        if ok and loc.minJob and loc.minJob ~= job and not isAdmin then
            ok = false
        end

        -- Job grade check
        if ok and IsFeatureOn('JobGrade') and loc.minJob and loc.minGrade then
            if loc.minJob == job and grade < loc.minGrade and not isAdmin then
                ok = false
            end
        end

        -- Time lock check
        if ok and not IsTimeAllowed(loc) then ok = false end

        if ok then
            local onCd, remaining = IsOnCooldown(loc)
            local cost = 0
            if IsFeatureOn('TeleportCost') then
                cost = loc.cost ~= nil and loc.cost or Config.Features.DefaultCost
            end

            table.insert(allowed, {
                id          = loc.id,
                name        = loc.name,
                cat         = loc.cat,
                tag         = loc.tag,
                dot         = loc.dot,
                label       = loc.label,
                coords      = string.format('X: %.1f  Y: %.1f  Z: %.1f', loc.x, loc.y, loc.z),
                onCooldown  = onCd,
                remaining   = remaining,
                cost        = cost,
                withVehicle = loc.withVehicle,
            })
        end
    end

    return allowed
end

-- ─────────────────────────────────────────────
--  OPEN / CLOSE MENU
-- ─────────────────────────────────────────────

local function SetMenuState(state)
    menuOpen = state
    SetNuiFocus(state, state)
    SendNUIMessage({ action = state and 'open' or 'close' })
end

local function OpenMenu()
    if menuOpen then return end

    if IsFeatureOn('DisableInVehicle') and IsPedInAnyVehicle(PlayerPedId(), false) then
        Notify('Cannot open TP menu while in a vehicle.', 'error')
        return
    end

    if IsFeatureOn('DisableInCombat') and IsPedInCombat(PlayerPedId(), 0) then
        Notify('Cannot open TP menu while in combat.', 'error')
        return
    end

    local playerData = ESX.GetPlayerData()
    menuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action    = 'open',
        locations = GetAllowedLocations(),
        position  = Config.MenuPosition,
        isAdmin   = (playerData.group == Config.AdminGroup),
        history   = IsFeatureOn('TPHistory') and tpHistory or nil,
        features  = {
            favorites = IsFeatureOn('Favorites'),
            tpHistory = IsFeatureOn('TPHistory'),
            cooldown  = IsFeatureOn('Cooldown'),
            cost      = IsFeatureOn('TeleportCost'),
            vehicleTp = IsFeatureOn('VehicleTeleport'),
        },
    })
end

-- ─────────────────────────────────────────────
--  ACTUAL TELEPORT
-- ─────────────────────────────────────────────

function ActuallyTeleport(loc, withVehicle)
    SetMenuState(false)
    SetCooldown(loc)

    local ped = PlayerPedId()

    -- Determine vehicle teleport
    local bringVehicle = false
    if IsFeatureOn('VehicleTeleport') then
        bringVehicle = loc.withVehicle ~= nil and loc.withVehicle or withVehicle
    end

    local vehicle = nil
    if bringVehicle and IsPedInAnyVehicle(ped, false) then
        vehicle = GetVehiclePedIsIn(ped, false)
    end

    if Config.FreezeOnTP then FreezeEntityPosition(ped, true) end

    if Config.BlackScreenTP then
        DoScreenFadeOut(500)
        Wait(500)
    end

    -- Load collision at destination
    RequestCollisionAtCoord(loc.x, loc.y, loc.z)
    local timeout = 0
    while not HasCollisionLoadedAroundEntity(ped) and timeout < 5000 do
        Wait(100)
        timeout = timeout + 100
    end

    if vehicle then
        SetEntityCoords(vehicle, loc.x, loc.y, loc.z, false, false, false, false)
        SetEntityHeading(vehicle, loc.heading or 0.0)
    else
        SetEntityCoords(ped, loc.x, loc.y, loc.z, false, false, false, false)
        SetEntityHeading(ped, loc.heading or 0.0)
    end

    if Config.FreezeOnTP then FreezeEntityPosition(ped, false) end

    if Config.BlackScreenTP then
        Wait(300)
        DoScreenFadeIn(500)
    end

    Notify('Teleported to ' .. loc.name)

    -- Add to history
    if IsFeatureOn('TPHistory') then
        table.insert(tpHistory, 1, {
            name   = loc.name,
            time   = string.format('%02d:%02d:%02d', GetClockHours(), GetClockMinutes(), GetClockSeconds()),
            coords = string.format('%.1f, %.1f, %.1f', loc.x, loc.y, loc.z),
        })
        if #tpHistory > (Config.Features.HistoryMaxEntries or 50) then
            table.remove(tpHistory)
        end
    end

    if Config.LogTeleports then
        TriggerServerEvent('snowman_tpmenu:log', loc.name, loc.x, loc.y, loc.z)
    end
end

-- ─────────────────────────────────────────────
--  TELEPORT — with cooldown + cost checks
-- ─────────────────────────────────────────────

local function DoTeleport(locationId, withVehicle)
    local loc = nil
    for _, l in ipairs(Config.Locations) do
        if l.id == locationId then loc = l break end
    end
    if not loc then return end

    -- Cooldown check
    local onCd, remaining = IsOnCooldown(loc)
    if onCd then
        Notify('Cooldown: ' .. remaining .. 's remaining.', 'error')
        return
    end

    -- Cost check — server deducts money and fires chargeResult
    local cost = IsFeatureOn('TeleportCost') and (loc.cost ~= nil and loc.cost or Config.Features.DefaultCost) or 0
    if cost > 0 then
        TriggerServerEvent('snowman_tpmenu:chargeMoney', locationId, cost)
        return  -- wait for chargeResult callback
    end

    ActuallyTeleport(loc, withVehicle)
end

-- ─────────────────────────────────────────────
--  NUI CALLBACKS
-- ─────────────────────────────────────────────

RegisterNUICallback('teleport', function(data, cb)
    cb('ok')
    Citizen.CreateThread(function()
        Wait(Config.TeleportDelay)
        DoTeleport(data.id, data.withVehicle)
    end)
end)

RegisterNUICallback('close', function(data, cb)
    cb('ok')
    SetMenuState(false)
end)

-- ─────────────────────────────────────────────
--  SERVER CALLBACKS
-- ─────────────────────────────────────────────

-- Money charge result from server
RegisterNetEvent('snowman_tpmenu:chargeResult')
AddEventHandler('snowman_tpmenu:chargeResult', function(locationId, success, reason)
    if not success then
        Notify(reason or 'Not enough money.', 'error')
        return
    end
    for _, l in ipairs(Config.Locations) do
        if l.id == locationId then
            ActuallyTeleport(l, false)
            return
        end
    end
end)

-- ─────────────────────────────────────────────
--  COMMANDS & KEY BINDING
-- ─────────────────────────────────────────────

RegisterCommand(Config.Command, function()
    if menuOpen then SetMenuState(false) else OpenMenu() end
end, false)

RegisterKeyMapping(Config.Command, 'Open Snowman TP Menu', 'keyboard', Config.OpenKey)

-- ESC closes menu
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if menuOpen and IsControlJustPressed(0, 177) then
            SetMenuState(false)
        end
    end
end)
