/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

PLUGIN.name = "Vanguard"
PLUGIN.description = "Vanguard is an admin system for the Helix Framework, it is designed to be very customizeable in terms of permissions, usergroups and settings. It is also designed to be very user-friendly and easy to use for both staff and players. Vanguard is lightweight and efficient in terms of performance, providing a great experience for all users. Shipped with a variety of features, Vanguard is the perfect admin system for your server."
PLUGIN.author = "Riggs"
PLUGIN.schema = "Any"
PLUGIN.version = "1.0"

ix.util.IncludeDir(PLUGIN.folder .. "/core", true)
ix.util.IncludeDir(PLUGIN.folder .. "/meta", true)
ix.util.IncludeDir(PLUGIN.folder .. "/hooks", true)

ix.vanguard = ix.vanguard or {}
ix.vanguard.core = PLUGIN