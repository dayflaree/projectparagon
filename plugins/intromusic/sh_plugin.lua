local PLUGIN = PLUGIN

PLUGIN.name = "Intro Music"
PLUGIN.description = "Plays music on character load."
PLUGIN.author = "Reece™"
PLUGIN.schema = "SCPRP"

PLUGIN.introMusic = {
    "projectparagon/gamesounds/scpcb/music/intro.ogg",
}

ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")