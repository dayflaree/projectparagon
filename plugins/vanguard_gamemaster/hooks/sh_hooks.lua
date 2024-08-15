/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

function PLUGIN:VanguardRegisterPrivileges()
    // Scene privileges
    ix.vanguard.core:RegisterPrivilege("Gamemaster - Scenes - View", "superadmin")
    ix.vanguard.core:RegisterPrivilege("Gamemaster - Scenes - Manage", "superadmin")

    // Sound privileges
    ix.vanguard.core:RegisterPrivilege("Gamemaster - Sounds - View", "superadmin")
    ix.vanguard.core:RegisterPrivilege("Gamemaster - Sounds - Manage", "superadmin")
end