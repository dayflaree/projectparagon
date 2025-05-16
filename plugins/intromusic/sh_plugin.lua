local PLUGIN = PLUGIN

PLUGIN.name = "Intro Music"
PLUGIN.description = "Plays music on character load."
PLUGIN.author = "Riggs"
PLUGIN.schema = "SCPRP"

PLUGIN.introMusic = {
    "projectparagon/sfx/Music/Intro.ogg",
}

ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")