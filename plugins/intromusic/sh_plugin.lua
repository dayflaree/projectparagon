local PLUGIN = PLUGIN

PLUGIN.name = "Intro Music"
PLUGIN.description = "Plays faction-specific music on character load."
PLUGIN.author = "Day"

--[[
    FACTION.introMusic = "projectparagon/sfx/Music/MyFactionIntro.ogg"

    FACTION.introMusic = {
        "projectparagon/sfx/Music/MyFactionTrack1.ogg",
        "projectparagon/sfx/Music/MyFactionTrack2.ogg",
    }
]]

ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")