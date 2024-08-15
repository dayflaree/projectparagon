/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

PLUGIN.name = "Vanguard Game Master Extension"
PLUGIN.description = "An extension for the Vanguard admin system plugin. It adds additional features for game masters. Such as creating scenes, managing music and sounds, and more."
PLUGIN.author = "Riggs"
PLUGIN.schema = "Any"

ix.util.IncludeDir(PLUGIN.folder .. "/core", true)
ix.util.IncludeDir(PLUGIN.folder .. "/meta", true)
ix.util.IncludeDir(PLUGIN.folder .. "/hooks", true)

ix.vanguard = ix.vanguard or {}
ix.vanguard.gamemaster = PLUGIN