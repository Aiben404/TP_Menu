Config = {}

-- ═══════════════════════════════════════════════
--  SNOWMAN TP MENU — CONFIG
-- ═══════════════════════════════════════════════

-- ─────────────────────────────────────────────
--  GENERAL
-- ─────────────────────────────────────────────

Config.OpenKey       = 'F5'        -- Key to open menu
Config.Command       = 'tpmenu'    -- Chat command (no slash)
Config.AdminGroup    = 'admin'     -- ESX group = admin
Config.VipGroup      = 'vip'       -- ESX group = vip
Config.TeleportDelay = 750         -- MS delay before TP fires
Config.FreezeOnTP    = true        -- Freeze player during TP
Config.BlackScreenTP = true        -- Black screen on TP
Config.LogTeleports  = true        -- Print TPs to server console

-- ─────────────────────────────────────────────
--  MENU POSITION
--  'top-left' | 'top-right' | 'bottom-left' | 'bottom-right' | 'center'
-- ─────────────────────────────────────────────

Config.MenuPosition = 'top-left'

-- ─────────────────────────────────────────────
--  OX_LIB NOTIFY
-- ─────────────────────────────────────────────

Config.Notify = {
    enabled  = true,
    type     = 'success',    -- success | error | inform | warning
    duration = 4000,
    position = 'top-right',
}

-- ─────────────────────────────────────────────
--  FEATURES — toggle each on/off with true/false
-- ─────────────────────────────────────────────

Config.Features = {

    -- ── Favorites ─────────────────────────────
    -- Players can star locations; they appear in a Favorites tab
    Favorites           = true,

    -- ── Cooldown ──────────────────────────────
    -- Prevent teleport spam. Per-location override via loc.cooldown
    Cooldown            = true,
    DefaultCooldown     = 30,           -- seconds (0 = no cooldown)

    -- ── Teleport Cost ─────────────────────────
    -- Deduct ESX money on teleport. Per-location override via loc.cost
    TeleportCost        = true,
    DefaultCost         = 0,            -- $ default (0 = free)
    CostAccount         = 'money',      -- ESX account: 'money' | 'bank'

    -- ── Vehicle Teleport ──────────────────────
    -- Teleport inside your current vehicle instead of leaving it behind
    VehicleTeleport     = true,

    -- ── TP History Log ────────────────────────
    -- Admins see a History tab with the last 50 teleports
    TPHistory           = true,
    HistoryMaxEntries   = 50,

    -- ── Job Grade Requirement ─────────────────
    -- Locations can require a minimum job grade (see loc.minGrade)
    JobGrade            = true,

    -- ── Whitelist by Identifier ───────────────
    -- Locations can have a whitelist of Discord/license IDs (see loc.whitelist)
    Whitelist           = true,

    -- ── Time-locked Locations ─────────────────
    -- Locations only accessible during certain server hours (see loc.hours)
    TimeLock            = true,

    -- ── Disable in Vehicle ────────────────────
    -- Block opening the menu while the player is in a vehicle
    DisableInVehicle    = true,

    -- ── Disable in Combat ─────────────────────
    -- Block teleport if player is currently in combat
    DisableInCombat     = true,
}

-- ─────────────────────────────────────────────
--  LOCATIONS
--
--  All fields:
--    id         - unique number (required)
--    name       - display name (required)
--    cat        - 'city' | 'jobs' | 'admin' | 'vip' (required)
--    tag        - 'free' | 'job' | 'admin' | 'vip'  (required)
--    dot        - 'green' | 'blue' | 'orange' | 'purple' | 'red' (required)
--    label      - badge text in UI (required)
--    x,y,z      - coordinates (required)
--    heading    - facing direction 0-360 (required)
--
--  Optional per-location overrides:
--    minJob     - require job name: e.g. 'police'
--    minGrade   - require minimum job grade: e.g. 2   (needs Features.JobGrade = true)
--    adminOnly  - true = only Config.AdminGroup
--    vipOnly    - true = only Config.VipGroup
--    cooldown   - seconds override (0 = no cooldown)  (needs Features.Cooldown = true)
--    cost       - money cost override                  (needs Features.TeleportCost = true)
--    withVehicle- true/false override vehicle TP       (needs Features.VehicleTeleport = true)
--    whitelist  - { 'discord:123', 'license:abc' }    (needs Features.Whitelist = true)
--    hours      - { from = 8, to = 20 }  server hours (needs Features.TimeLock = true)
-- ─────────────────────────────────────────────

Config.Locations = {

    -- ── CITY ──────────────────────────────────
    {
        id      = 1,
        name    = 'Mission Row PD',
        cat     = 'city',
        tag     = 'job',
        dot     = 'blue',
        label   = 'POLICE',
        x       = 441.3,  y = -982.2,  z = 30.7,
        heading = 90.0,
        minJob  = 'police',
        minGrade = 0,
    },
    {
        id      = 2,
        name    = 'Pillbox Hospital',
        cat     = 'city',
        tag     = 'job',
        dot     = 'blue',
        label   = 'EMS',
        x       = 297.5,  y = -584.3,  z = 43.3,
        heading = 0.0,
        minJob  = 'ambulance',
        minGrade = 0,
    },
    {
        id      = 3,
        name    = 'Legion Square',
        cat     = 'city',
        tag     = 'free',
        dot     = 'green',
        label   = 'PUBLIC',
        x       = 195.2,  y = -933.5,  z = 30.7,
        heading = 0.0,
    },
    {
        id      = 4,
        name    = 'Maze Bank Arena',
        cat     = 'city',
        tag     = 'free',
        dot     = 'green',
        label   = 'PUBLIC',
        x       = -238.0, y = -2038.0, z = 20.0,
        heading = 0.0,
    },
    {
        id      = 5,
        name    = 'Airport (LSIA)',
        cat     = 'city',
        tag     = 'free',
        dot     = 'green',
        label   = 'PUBLIC',
        x       = -1037.0, y = -2738.0, z = 20.2,
        heading = 0.0,
        cost    = 50,   -- example: $50 to TP to airport
    },
    {
        id      = 6,
        name    = 'Sandy Shores',
        cat     = 'city',
        tag     = 'free',
        dot     = 'green',
        label   = 'PUBLIC',
        x       = 1853.3, y = 3687.1, z = 34.3,
        heading = 0.0,
    },
    {
        id      = 7,
        name    = 'Paleto Bay',
        cat     = 'city',
        tag     = 'free',
        dot     = 'green',
        label   = 'PUBLIC',
        x       = -224.2, y = 6330.2, z = 32.4,
        heading = 0.0,
    },
    {
        id      = 8,
        name    = 'Vinewood Hills',
        cat     = 'city',
        tag     = 'vip',
        dot     = 'purple',
        label   = 'VIP',
        x       = -460.3, y = 215.8, z = 91.2,
        heading = 0.0,
        vipOnly = true,
        -- Example: only available 18:00–06:00
        hours   = { from = 18, to = 6 },
    },

    -- ── JOBS ──────────────────────────────────
    {
        id      = 9,
        name    = 'Mechanic Shop',
        cat     = 'jobs',
        tag     = 'job',
        dot     = 'orange',
        label   = 'JOB',
        x       = -356.6, y = -133.9, z = 38.7,
        heading = 180.0,
        minJob  = 'mechanic',
        minGrade = 0,
    },
    {
        id      = 10,
        name    = 'Cocaine Lab',
        cat     = 'jobs',
        tag     = 'job',
        dot     = 'orange',
        label   = 'JOB',
        x       = 1104.6, y = -3191.3, z = 5.9,
        heading = 45.0,
        cooldown = 60,  -- 60s cooldown on this location
    },
    {
        id      = 11,
        name    = 'Weed Farm',
        cat     = 'jobs',
        tag     = 'job',
        dot     = 'orange',
        label   = 'JOB',
        x       = 1102.5, y = 2195.4, z = 44.1,
        heading = 0.0,
        cooldown = 60,
    },
    {
        id      = 12,
        name    = 'Trucking Depot',
        cat     = 'jobs',
        tag     = 'job',
        dot     = 'orange',
        label   = 'JOB',
        x       = 54.2, y = -1754.5, z = 29.6,
        heading = 270.0,
        minJob  = 'trucker',
        minGrade = 1,  -- must be grade 1+ trucker
    },
    {
        id      = 13,
        name    = 'Taxi Company',
        cat     = 'jobs',
        tag     = 'job',
        dot     = 'blue',
        label   = 'JOB',
        x       = 908.7, y = -160.9, z = 74.0,
        heading = 0.0,
        minJob  = 'taxi',
    },
    {
        id      = 14,
        name    = 'Gun Shop',
        cat     = 'jobs',
        tag     = 'job',
        dot     = 'orange',
        label   = 'JOB',
        x       = 15.3, y = -1108.9, z = 29.8,
        heading = 180.0,
        -- Example: only open during business hours
        hours   = { from = 8, to = 22 },
    },

    -- ── VIP ───────────────────────────────────
    {
        id      = 15,
        name    = 'VIP Penthouse',
        cat     = 'vip',
        tag     = 'vip',
        dot     = 'purple',
        label   = 'VIP',
        x       = -46.6, y = -584.7, z = 193.0,
        heading = 0.0,
        vipOnly = true,
        -- Example whitelist (Discord IDs)
        -- whitelist = { 'discord:123456789', 'license:abc123' },
    },
    {
        id      = 16,
        name    = 'VIP Garage',
        cat     = 'vip',
        tag     = 'vip',
        dot     = 'purple',
        label   = 'VIP',
        x       = -362.5, y = -134.4, z = 38.7,
        heading = 90.0,
        vipOnly = true,
        withVehicle = true,  -- always bring vehicle here
    },
    {
        id      = 17,
        name    = 'VIP Casino Floor',
        cat     = 'vip',
        tag     = 'vip',
        dot     = 'purple',
        label   = 'VIP',
        x       = 921.5, y = 47.0, z = 80.9,
        heading = 0.0,
        vipOnly = true,
        cost    = 500,  -- $500 VIP casino entry
    },

    -- ── ADMIN ─────────────────────────────────
    {
        id        = 18,
        name      = 'Admin Room',
        cat       = 'admin',
        tag       = 'admin',
        dot       = 'red',
        label     = 'ADMIN',
        x         = 0.0,   y = 0.0,   z = 100.0,
        heading   = 0.0,
        adminOnly = true,
        cooldown  = 0,
    },
    {
        id        = 19,
        name      = 'Test Coords',
        cat       = 'admin',
        tag       = 'admin',
        dot       = 'red',
        label     = 'ADMIN',
        x         = 100.0, y = 100.0, z = 40.0,
        heading   = 0.0,
        adminOnly = true,
        cooldown  = 0,
    },
    {
        id        = 20,
        name      = 'Skybox / Void',
        cat       = 'admin',
        tag       = 'admin',
        dot       = 'red',
        label     = 'ADMIN',
        x         = 0.0,   y = 0.0,   z = 3000.0,
        heading   = 0.0,
        adminOnly = true,
        cooldown  = 0,
    },
}
