/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

PLUGIN.permissions = PLUGIN.permissions or {}

PLUGIN.defaultUsergroups = PLUGIN.defaultUsergroups or {}
PLUGIN.defaultUsergroups["user"] = {
    DisplayName = "User",
    DisplayDescription = "A member of the server.",
    Description = "The default usergroup for all players.",
    Color = Color(200, 200, 200),
    Icon = "icon16/user.png",
    Inherits = "user",
    Order = 100,
    DonatorPrivileges = false,
    CanEdit = true,
    CanDelete = false
}

PLUGIN.defaultUsergroups["admin"] = {
    DisplayName = "Admin",
    DisplayDescription = "An administrator of the server.",
    Description = "The default usergroup for all staff members.",
    Color = Color(255, 0, 0),
    Icon = "icon16/shield.png",
    Inherits = "user",
    Order = 200,
    DonatorPrivileges = true,
    CanEdit = true,
    CanDelete = false
}

PLUGIN.defaultUsergroups["superadmin"] = {
    DisplayName = "Super Admin",
    DisplayDescription = "A super administrator of the server.",
    Description = "The default usergroup for all super administrators.",
    Color = Color(0, 0, 255),
    Icon = "icon16/shield_add.png",
    Inherits = "admin",
    Order = 300,
    DonatorPrivileges = true,
    CanEdit = true,
    CanDelete = false
}

function PLUGIN:CanPlayerTargetUsergroup(ply, usergroup)
    if ( !IsValid(ply) ) then
        return false, "Invalid player"
    end

    local plyUsergroup = ply:GetUserGroup()
    plyUsergroup = CAMI.GetUsergroup(plyUsergroup)

    if ( !plyUsergroup ) then
        return false, "Not a valid usergroup"
    end

    if ( !usergroup ) then
        return true
    end

    if ( plyUsergroup.Name == usergroup ) then
        return true
    end

    usergroup = CAMI.GetUsergroup(usergroup)

    if ( !usergroup ) then
        return false, "Not a valid usergroup"
    end

    local plyOrder = plyUsergroup.Order
    local usergroupOrder = usergroup.Order

    if ( plyOrder <= usergroupOrder ) then
        return false, "You cannot target this usergroup due to usergroup restrictions!"
    end

    return true
end

function PLUGIN:CanPlayerTarget(ply, target, usergroup)
    if ( !IsValid(ply) or !IsValid(target) ) then
        return false, "Invalid player(s)"
    end

    if ( ply == target ) then
        return true
    end

    local plyUsergroup = ply:GetUserGroup()
    plyUsergroup = CAMI.GetUsergroup(plyUsergroup)

    if ( !plyUsergroup ) then
        return false, "Not a valid usergroup"
    end

    local targetUsergroup = target:GetUserGroup()
    targetUsergroup = CAMI.GetUsergroup(targetUsergroup)

    if ( !targetUsergroup ) then
        return false, "Not a valid usergroup for target"
    end

    if ( !usergroup ) then
        if ( plyUsergroup.Order < targetUsergroup.Order ) then
            return false, "You cannot target this player!"
        end
    else
        usergroup = CAMI.GetUsergroup(usergroup)

        if ( !usergroup ) then
            return false, "Not a valid usergroup"
        end

        local plyOrder = plyUsergroup.Order
        local targetOrder = targetUsergroup.Order
        local usergroupOrder = usergroup.Order

        if ( plyOrder <= targetOrder or plyOrder <= usergroupOrder ) then
            return false, "You cannot target this player due to usergroup restrictions!"
        end
    end 

    return true
end

function PLUGIN:FindUsergroup(identifier)
    for k, v in pairs(CAMI.GetUsergroups()) do
        if ( ix.util.StringMatches(v.Name, identifier) or ix.util.StringMatches(v.DisplayName, identifier) or ix.util.StringMatches(k, identifier) ) then
            return v
        end
    end
end

// returns the default value for the privilege based on the usergroup
function PLUGIN:GetDefaultPrivilege(usergroup, privilege)
    if ( !usergroup or !privilege ) then
        return false
    end

    local usergroupData = CAMI.GetUsergroup(usergroup)
    if ( !usergroupData ) then
        return false
    end

    for k, v in pairs(CAMI.GetPrivileges()) do
        if ( v.Name == privilege ) then
            if ( v.MinAccess == "superadmin" and ( usergroup == "superadmin" or usergroupData.Inherits == "superadmin" ) ) then
                return true
            end

            if ( v.MinAccess == "admin" and ( usergroup == "admin" or usergroupData.Inherits == "admin" ) ) then
                return true
            end

            if ( v.MinAccess == "user" ) then
                return true
            end
        end
    end

    return false
end