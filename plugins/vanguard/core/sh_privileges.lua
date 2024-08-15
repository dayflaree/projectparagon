/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

local privileges = {}
function PLUGIN:RegisterPrivilege(name, minAccess)
    CAMI.RegisterPrivilege({
        Name = "Helix - Vanguard " .. name,
        MinAccess = minAccess
    })

    privileges[name] = "Helix - Vanguard " .. name

    return "Helix - Vanguard " .. name
end

function PLUGIN:GetPrivileges()
    return privileges
end

function PLUGIN:RegisterPrivileges()
    // PAC3 privileges
    PLUGIN:RegisterPrivilege("PAC3 - View", "superadmin")
    PLUGIN:RegisterPrivilege("PAC3 - Edit", "superadmin")

    // Usergroup privileges
    PLUGIN:RegisterPrivilege("Usergroups - View", "superadmin")
    PLUGIN:RegisterPrivilege("Usergroups - Manage", "superadmin")

    // Chat privileges
    PLUGIN:RegisterPrivilege("Chat - Staff Chat", "admin")
    PLUGIN:RegisterPrivilege("Chat - Game Master Chat", "admin")
    PLUGIN:RegisterPrivilege("Chat - Higher Up Chat", "admin")
    PLUGIN:RegisterPrivilege("Chat - Mute", "admin")
    PLUGIN:RegisterPrivilege("Chat - Unmute", "admin")

    // Log privileges
    PLUGIN:RegisterPrivilege("Logs - View", "admin")

    // Ticket privileges
    PLUGIN:RegisterPrivilege("Tickets - Claim", "admin")
    PLUGIN:RegisterPrivilege("Tickets - Close", "admin")
    PLUGIN:RegisterPrivilege("Tickets - Create", "user")
    PLUGIN:RegisterPrivilege("Tickets - Reply", "admin")
    PLUGIN:RegisterPrivilege("Tickets - View", "admin")

    // Spawning privileges
    PLUGIN:RegisterPrivilege("Spawn - Blacklisted Models", "superadmin")
    PLUGIN:RegisterPrivilege("Spawn - NPC", "superadmin")
    PLUGIN:RegisterPrivilege("Spawn - Entity", "superadmin")
    PLUGIN:RegisterPrivilege("Spawn - Entity (Protected)", "superadmin")
    PLUGIN:RegisterPrivilege("Spawn - Vehicles", "superadmin")
    PLUGIN:RegisterPrivilege("Spawn - Weapons", "superadmin")
    PLUGIN:RegisterPrivilege("Spawn - Items", "superadmin")
    PLUGIN:RegisterPrivilege("Spawn - Effects", "superadmin")

    // Prop privileges
    PLUGIN:RegisterPrivilege("Props - Blacklist", "superadmin")
    PLUGIN:RegisterPrivilege("Props - Unblacklist", "superadmin")
    PLUGIN:RegisterPrivilege("Props - View", "superadmin")
    PLUGIN:RegisterPrivilege("Props - Bypass", "superadmin")

    // Tool privileges
    PLUGIN:RegisterPrivilege("Tools - Restrict", "superadmin")
    PLUGIN:RegisterPrivilege("Tools - Unrestrict", "superadmin")
    PLUGIN:RegisterPrivilege("Tools - View", "superadmin")
    PLUGIN:RegisterPrivilege("Tools - Bypass", "superadmin")

    // Blacklist privileges
    PLUGIN:RegisterPrivilege("Blacklist - Add", "superadmin")
    PLUGIN:RegisterPrivilege("Blacklist - Remove", "superadmin")
    PLUGIN:RegisterPrivilege("Blacklist - View", "superadmin")

    // Inventory privileges
    PLUGIN:RegisterPrivilege("Inventory - View", "admin")

    hook.Run("VanguardRegisterPrivileges", PLUGIN)
end

hook.Add("InitPostEntity", "Vanguard.InitPostEntity.Privileges", function()
    PLUGIN:RegisterPrivileges()
end)

hook.Add("OnReloaded", "Vanguard.Reloaded.Privileges", function()
    PLUGIN:RegisterPrivileges()
end)