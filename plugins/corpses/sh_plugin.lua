local PLUGIN = PLUGIN

PLUGIN.name = "Corpses"
PLUGIN.description = "Adds an inventory to dead player corpses and npcs."
PLUGIN.author = "Riggs"
PLUGIN.schema = "Any"

PLUGIN.factionDrops = {}

if ( FACTION_MPF ) then
    PLUGIN.factionDrops[FACTION_MPF] = {
        ["health_vial"] = 50, // 50% chance
    }
end

if ( FACTION_OTA ) then
    PLUGIN.factionDrops[FACTION_OTA] = {
        ["health_vial"] = 35, // 35% chance
    }
end

PLUGIN.npcDrops = {
    ["npc_metropolice"] = {
        ["health_vial"] = 50, // 50% chance
    },
    ["npc_combine_s"] = {
        ["health_vial"] = 35, // 25% chance
    },
}

ix.util.Include("sv_hooks.lua")