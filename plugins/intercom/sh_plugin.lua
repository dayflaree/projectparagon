local PLUGIN = PLUGIN

PLUGIN.name = "Intercom System"
PLUGIN.author = "Day"
PLUGIN.description = "Allows authorized factions to broadcast their voice globally via an entity."
PLUGIN.version = "1.0"

-- CONFIGURATION --
PLUGIN.intercomEntityClass = "pp_intercom" -- The entity class name

PLUGIN.allowedFactionIDs = {
    FACTION_MAINTENANCE,
    FACTION_MEDICAL,
    FACTION_SCIENTIFIC,
    FACTION_SECURITY,
    FACTION_MTF,
    FACTION_SITEDIRECTOR
}

PLUGIN.personalCooldown = 600
PLUGIN.globalCooldown = 120
PLUGIN.broadcastDuration = 60

PLUGIN.soundActivate = "projectparagon/sfx/Interact/ScannerUse1.ogg"
PLUGIN.soundDenied = "projectparagon/sfx/Interact/ScannerUse2.ogg"
PLUGIN.soundBroadcastStart = "projectparagon/sfx/Room/Intro/PA/on.ogg"
PLUGIN.soundBroadcastEnd = "projectparagon/sfx/Room/Intro/PA/off.ogg"

-- This function will be called by the entity when used.
-- The actual implementation is in sv_hooks.lua.
function PLUGIN:PlayerAttemptUseIntercom(ply, entity)
    -- Server-side logic will handle this
end

if (SERVER) then
    -- Initialize cooldown tracking tables
    PLUGIN.playerCooldowns = PLUGIN.playerCooldowns or {} -- [SteamID64] = NextAvailableTime
    PLUGIN.nextGlobalUseTime = PLUGIN.nextGlobalUseTime or 0
end

-- Make sure there are no nils in allowedFactionIDs due to undefined constants
-- This is a basic check; a more robust check would happen after schema init if needed.
local tempAllowedIDs = {}
for _, id in ipairs(PLUGIN.allowedFactionIDs or {}) do
    if id ~= nil then
        table.insert(tempAllowedIDs, id)
    else
        ix.log.Warning("[Intercom Plugin] A faction constant in PLUGIN.allowedFactionIDs was nil. Check your schema's faction definitions and load order.")
    end
end
PLUGIN.allowedFactionIDs = tempAllowedIDs

ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_hooks.lua")