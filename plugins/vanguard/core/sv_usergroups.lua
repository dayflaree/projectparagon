/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

PLUGIN.permissions = PLUGIN.permissions or {}

function PLUGIN:PlayerSetUserGroup(ply, target, usergroup)
    if ( !IsValid(ply) or !IsValid(target) or !usergroup ) then
        return false, L("vanguard_cmd_setusergroup_callback_invalid", ply)
    end

    if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Usergroups - Manage", nil) ) then
        return false, L("vanguard_cmd_setusergroup_callback_access", ply)
    end

    if ( !CAMI.GetUsergroup(usergroup) ) then
        return false, L("vanguard_cmd_setusergroup_callback_exists", ply, usergroup)
    end

    if ( target:GetUserGroup() == usergroup ) then
        return false, L("vanguard_cmd_setusergroup_callback_same", ply, usergroup)
    end

    local can, err = hook.Run("CanPlayerTarget", ply, target, usergroup)
    if ( can == false ) then
        return false, err
    end
    
    target:SetUserGroup(usergroup)
    target:SetData("Vanguard.UserGroup", usergroup)
    target:SaveData()
            
    if ( target != ply ) then
        ply:NotifyLocalized("vanguard_cmd_setusergroup_callback", target:GetName(), usergroup)
    elseif ( target == ply ) then
        target:NotifyLocalized("vanguard_cmd_setusergroup_callback_self", usergroup)
    else
        target:NotifyLocalized("vanguard_cmd_setusergroup_callback_target", usergroup, ply:GetName())
    end

    return true
end

function PLUGIN:SaveUserGroups()
    local usergroups = CAMI.GetUsergroups()
    for key, data in pairs(usergroups) do
        data.Permissions = nil
    end

    ix.data.Set("usergroups", usergroups, false, true)
end

function PLUGIN:LoadUserGroups()
    for key, data in pairs(CAMI.GetUsergroups()) do
        CAMI.UnregisterUsergroup(data.Name)
    end
    
    local default = ix.data.Get("usergroups", self.defaultUsergroups, false, true, true)
    if ( !default or table.IsEmpty(default) ) then
        default = self.defaultUsergroups
    end

    for key, data in pairs(default) do
        data.Name = key

        local can, err = self:CreateUserGroup(data, true, data.Inherits)
        if ( can == false ) then
            MsgC(Color(255, 0, 0), "[Helix] [Vanguard] Error loading usergroup: " .. key .. " (" .. tostring(err) .. ")\n")
        end
    end

    self:SaveUserGroups()
    self:SyncUserGroups()

    for k, v in player.Iterator() do
        local usergroup = v:GetData("Vanguard.UserGroup", "user")
        if ( !CAMI.GetUsergroup(usergroup) ) then
            v:SetUserGroup("user")
            v:SetData("Vanguard.UserGroup", "user")
            v:SaveData()
        end
    end
end

ix.log.AddType("vanguard_reset_usergroups", function(ply, ...)
    local name = "Console"
    if ( IsValid(ply) ) then
        name = ply:GetName() .. " (" .. ply:SteamID64() .. ")"
    end

    return string.format("%s has reset all usergroups.", name)
end, FLAG_DANGER)

function PLUGIN:ResetUserGroups(ply)
    for key, data in pairs(CAMI.GetUsergroups()) do
        CAMI.UnregisterUsergroup(data.Name)
    end

    ix.data.Set("usergroups", nil, false, true)
    ix.data.Set("usergroup_permissions", nil, false, true)

    self:LoadUserGroups()

    ix.log.Add(ply, "vanguard_reset_usergroups")
end

util.AddNetworkString("ixVanguardUsergroupsSync")
function PLUGIN:SyncUserGroups(delay, players)
    if ( delay ) then
        timer.Simple(delay, function()
            self:SyncUserGroups()
        end)
        
        return
    end

    if ( !players ) then
        players = {}

        for _, v in player.Iterator() do
            if ( !IsValid(v) ) then
                continue
            end
            
            players[#players + 1] = v
        end

        if ( #players == 0 ) then
            return
        end
    end

    self.permissions = ix.data.Get("usergroup_permissions", {}, false, true)
    
    local usergroups = CAMI.GetUsergroups()
    local permissions = self.permissions

    local combined = {usergroups, permissions}
    combined = util.TableToJSON(combined)
    combined = util.Compress(combined)
    
    local totalLength = #combined
    local chunkSize = 8192 // 8KB
    local numChunks = math.ceil(totalLength / chunkSize)

    // Send the number of chunks to the client first
    net.Start("ixVanguardUsergroupsSync")
        net.WriteUInt(numChunks, 32)
    net.Send(players)

    // Function to send each chunk
    local function SendChunk(chunkIndex)
        local startByte = (chunkIndex - 1) * chunkSize + 1
        local endByte = math.min(chunkIndex * chunkSize, totalLength)
        local chunkData = string.sub(combined, startByte, endByte)

        net.Start("ixVanguardUsergroupsSync")
            net.WriteUInt(chunkIndex, 32) // Chunk index
            net.WriteUInt(#chunkData, 32) // Chunk size
            net.WriteData(chunkData, #chunkData)
        net.Send(players)
    end

    // Send all chunks
    for i = 1, numChunks do
        SendChunk(i)
    end
end

function PLUGIN:CreateUserGroup(data, bSkipSave, copyPermissionsFrom)
    if ( !data ) then
        return false, "No data provided!"
    end

    if ( CAMI.GetUsergroup(data.Name) ) then
        return false, "A usergroup with the name \"" .. data.Name .. "\" already exists!"
    end

    local permissions = ix.data.Get("usergroup_permissions", {}, false, true)
    if ( !permissions ) then
        permissions = {}
    end

    // comment: checks if new privileges are added in the future and adds them to the usergroup, and then checks if the privileges are supposed to be enabled or disabled
    for k, v in pairs(CAMI.GetPrivileges()) do
        if ( !permissions[k] ) then
            permissions[k] = {}
        end

        if ( copyPermissionsFrom ) then
            local copyData = permissions[copyPermissionsFrom]
            if ( copyData ) then
                permissions[k] = table.Copy(copyData)
            end
        end

        if ( table.HasValue(permissions[k], data.Name) ) then
            continue
        end

        if ( v.MinAccess == "user" ) then
            table.insert(permissions[k], data.Name)
        end

        if ( v.MinAccess == "admin" and ( data.Name == "admin" or data.Inherits == "admin" ) ) then
            table.insert(permissions[k], data.Name)
        end

        if ( v.MinAccess == "superadmin" and ( data.Name == "superadmin" or data.Inherits == "superadmin" ) ) then
            table.insert(permissions[k], data.Name)
        end
    end

    ix.data.Set("usergroup_permissions", permissions, false, true)

    CAMI.RegisterUsergroup(data, "Vanguard")

    if ( !bSkipSave ) then
        self:SaveUserGroups()
        self:SyncUserGroups()
    end

    return key
end

function PLUGIN:DeleteUserGroup(name)
    if ( !name ) then
        return false, "No name provided!"
    end

    local data = CAMI.GetUsergroup(name)
    if ( !data ) then
        return false, "Usergroup does not exist!"
    end

    if ( data.CanDelete == false ) then
        return false, "Usergroup cannot be deleted!"
    end

    CAMI.UnregisterUsergroup(data.Name)

    self:SaveUserGroups()
    self:SyncUserGroups()

    return data
end

function PLUGIN:UpdateUserGroup(usergroup, key, data)
    if ( !usergroup or !key or !data ) then
        return false, "Invalid data provided!"
    end

    local usergroupData = CAMI.GetUsergroup(usergroup)
    if ( !usergroupData ) then
        return false, "Usergroup does not exist!"
    end

    if ( key == "Name" ) then
        return false, "Cannot change the key name of a usergroup!"
    end

    usergroupData[key] = data

    self:SaveUserGroups()
    self:SyncUserGroups()

    return true
end

function PLUGIN:UpdateUserGroupPrivilege(usergroup, privilege, value)
    if ( !usergroup or !privilege or value == nil ) then
        return false, "Invalid data provided!"
    end

    local usergroupData = CAMI.GetUsergroup(usergroup)
    if ( !usergroupData ) then
        return false, "Usergroup does not exist!"
    end
    
    if ( usergroupData.CanEdit == false ) then
        return false, "Usergroup cannot be edited!"
    end

    local permissions = ix.data.Get("usergroup_permissions", {}, false, true)
    if ( !permissions[privilege] ) then
        permissions[privilege] = {}
    end

    if ( value and !table.HasValue(permissions[privilege], usergroup) ) then
        table.insert(permissions[privilege], usergroup)
    elseif ( !value and table.HasValue(permissions[privilege], usergroup) ) then
        table.RemoveByValue(permissions[privilege], usergroup)
    end

    ix.data.Set("usergroup_permissions", permissions, false, true)

    self:SaveUserGroups()
    self:SyncUserGroups()

    return true
end

local nextNet = 0

util.AddNetworkString("ixVanguardCreateUsergroup")
net.Receive("ixVanguardCreateUsergroup", function(len, ply)
    if ( !IsValid(ply) ) then return end
    if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Usergroups - Manage", nil) ) then return end

    local name = net.ReadString()
    if ( !name ) then return end

    local inherit = net.ReadString()
    if ( !inherit ) then return end

    if ( nextNet > CurTime() ) then
        ply:NotifyLocalized("vanguard_net_spam")
        return
    end

    nextNet = CurTime() + 0.1

    local uniqueName = string.lower(name)
    uniqueName = string.gsub(uniqueName, "%s", "")
    uniqueName = uniqueName:sub(1, 1):upper() .. uniqueName:sub(2)

    local data, message = PLUGIN:CreateUserGroup({
        Name = uniqueName:lower(),
        FunctionName = uniqueName,
        DisplayName = uniqueName,
        Order = 100,
        Icon = "icon16/user.png",
        Inherits = inherit,
        Color = Color(200, 200, 200)
    }, false, inherit)

    if ( data ) then
        ply:NotifyLocalized("vanguard_usergroup_created", data.Name, data.Inherits)

        // comment: only save and sync usergroups if the usergroup was created successfully
        PLUGIN:SaveUserGroups()
        PLUGIN:SyncUserGroups()
    end

    if ( message ) then
        ply:NotifyLocalized(message)
    end
end)

util.AddNetworkString("ixVanguardUpdateUsergroup")
net.Receive("ixVanguardUpdateUsergroup", function(len, ply)
    if ( !IsValid(ply) ) then return end
    if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Usergroups - Manage", nil) ) then return end

    local usergroup = net.ReadString()
    if ( !usergroup ) then return end

    local key = net.ReadString()
    if ( !key ) then return end

    local data = net.ReadType()
    if ( !data ) then return end

    if ( nextNet > CurTime() ) then
        ply:NotifyLocalized("vanguard_net_spam")
        return
    end

    nextNet = CurTime() + 0.1

    local can, err = hook.Run("CanPlayerTargetUsergroup", ply, usergroup)
    if ( can == false ) then
        ply:NotifyLocalized(err)
        return
    end

    local updatedData, message = PLUGIN:UpdateUserGroup(usergroup, key, data)
    if ( updatedData ) then
        ply:NotifyLocalized("vanguard_usergroup_updated", usergroup, key, data)
    end

    if ( message ) then
        ply:NotifyLocalized(message)
    end
end)

util.AddNetworkString("ixVanguardUpdateUsergroupPrivilege")
net.Receive("ixVanguardUpdateUsergroupPrivilege", function(len, ply)
    if ( !IsValid(ply) ) then return end
    if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Usergroups - Manage", nil) ) then return end

    local usergroup = net.ReadString()
    if ( !usergroup ) then return end

    local privilege = net.ReadString()
    if ( !privilege ) then return end

    local value = net.ReadBool()
    if ( value == nil ) then return end

    if ( nextNet > CurTime() ) then
        ply:NotifyLocalized("vanguard_net_spam")
        return
    end

    nextNet = CurTime() + 0.1

    local can, err = hook.Run("CanPlayerTargetUsergroup", ply, usergroup)
    if ( can == false ) then
        ply:NotifyLocalized(err)
        return
    end

    local data, message = PLUGIN:UpdateUserGroupPrivilege(usergroup, privilege, value)
    if ( data ) then
        ply:NotifyLocalized("vanguard_usergroup_privilege_updated", privilege, usergroup, value)
    end

    if ( message ) then
        ply:NotifyLocalized(message)
    end
end)

util.AddNetworkString("ixVanguardDeleteUsergroup")
net.Receive("ixVanguardDeleteUsergroup", function(len, ply)
    if ( !IsValid(ply) ) then return end
    if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Usergroups - Manage", nil) ) then return end

    local name = net.ReadString()
    if ( !name ) then return end

    if ( nextNet > CurTime() ) then
        ply:NotifyLocalized("vanguard_net_spam")
        return
    end

    nextNet = CurTime() + 0.1

    local can, err = hook.Run("CanPlayerTargetUsergroup", ply, usergroup)
    if ( can == false ) then
        ply:NotifyLocalized(err)
        return
    end

    local data, message = PLUGIN:DeleteUserGroup(name)
    if ( data ) then
        ply:NotifyLocalized("vanguard_usergroup_deleted", data.Name)
    end

    if ( message ) then
        ply:NotifyLocalized(message)
    end
end)

util.AddNetworkString("ixVanguardDuplicateUsergroup")
net.Receive("ixVanguardDuplicateUsergroup", function(len, ply)
    if ( !IsValid(ply) ) then return end
    if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Usergroups - Manage", nil) ) then return end

    local name = net.ReadString()
    if ( !name ) then return end

    local newName = net.ReadString()
    if ( !newName ) then return end

    if ( nextNet > CurTime() ) then
        ply:NotifyLocalized("vanguard_net_spam")
        return
    end

    nextNet = CurTime() + 0.1

    local uniqueName = string.lower(newName)
    uniqueName = string.gsub(uniqueName, "%s", "")
    uniqueName = uniqueName:sub(1, 1):upper() .. uniqueName:sub(2)

    local data = CAMI.GetUsergroup(name)
    if ( !data ) then
        return
    end

    local newData = table.Copy(data)
    newData.Name = uniqueName:lower()
    newData.FunctionName = uniqueName
    newData.CanEdit = nil
    newData.CanDelete = nil

    local data, message = PLUGIN:CreateUserGroup(newData, false, inherit)
    if ( data ) then
        ply:NotifyLocalized("vanguard_usergroup_created", data.Name, data.Inherits)

        // comment: only save and sync usergroups if the usergroup was created successfully
        PLUGIN:SaveUserGroups()
        PLUGIN:SyncUserGroups()
    end

    if ( message ) then
        ply:NotifyLocalized(message)
    end
end)

util.AddNetworkString("ixVanguardGrantAllPermissions")
net.Receive("ixVanguardGrantAllPermissions", function(len, ply)
    if ( !IsValid(ply) ) then return end
    if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Usergroups - Manage", nil) ) then return end

    local usergroup = net.ReadString()
    if ( !usergroup ) then return end

    if ( nextNet > CurTime() ) then
        ply:NotifyLocalized("vanguard_net_spam")
        return
    end

    nextNet = CurTime() + 0.1

    local can, err = hook.Run("CanPlayerTargetUsergroup", ply, usergroup)
    if ( can == false ) then
        ply:NotifyLocalized(err)
        return
    end

    local permissions = ix.data.Get("usergroup_permissions", {}, false, true)
    for k, v in pairs(CAMI.GetPrivileges()) do
        if ( !permissions[k] ) then
            permissions[k] = {}
        end

        if ( !table.HasValue(permissions[k], usergroup) ) then
            table.insert(permissions[k], usergroup)
        end
    end

    ix.data.Set("usergroup_permissions", permissions, false, true)

    PLUGIN:SaveUserGroups()
    PLUGIN:SyncUserGroups()

    ply:NotifyLocalized("vanguard_usergroup_granted_all", usergroup)
end)

util.AddNetworkString("ixVanguardRevokeAllPermissions")
net.Receive("ixVanguardRevokeAllPermissions", function(len, ply)
    if ( !IsValid(ply) ) then return end
    if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Usergroups - Manage", nil) ) then return end

    local usergroup = net.ReadString()
    if ( !usergroup ) then return end

    if ( nextNet > CurTime() ) then
        ply:NotifyLocalized("vanguard_net_spam")
        return
    end

    nextNet = CurTime() + 0.1

    local can, err = hook.Run("CanPlayerTargetUsergroup", ply, usergroup)
    if ( can == false ) then
        ply:NotifyLocalized(err)
        return
    end

    local permissions = ix.data.Get("usergroup_permissions", {}, false, true)
    for k, v in pairs(CAMI.GetPrivileges()) do
        if ( !permissions[k] ) then
            permissions[k] = {}
        end

        if ( table.HasValue(permissions[k], usergroup) ) then
            table.RemoveByValue(permissions[k], usergroup)
        end
    end

    ix.data.Set("usergroup_permissions", permissions, false, true)

    PLUGIN:SaveUserGroups()
    PLUGIN:SyncUserGroups()

    ply:NotifyLocalized("vanguard_usergroup_revoked_all", usergroup)
end)

util.AddNetworkString("ixVanguardResetAllPermissions")
net.Receive("ixVanguardResetAllPermissions", function(len, ply)
    if ( !IsValid(ply) ) then return end
    if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Usergroups - Manage", nil) ) then return end

    local usergroup = net.ReadString()
    if ( !usergroup ) then return end

    local data = CAMI.GetUsergroup(usergroup)
    if ( !data ) then return end

    if ( nextNet > CurTime() ) then
        ply:NotifyLocalized("vanguard_net_spam")
        return
    end

    nextNet = CurTime() + 0.1

    local can, err = hook.Run("CanPlayerTargetUsergroup", ply, usergroup)
    if ( can == false ) then
        ply:NotifyLocalized(err)
        return
    end

    local permissions = ix.data.Get("usergroup_permissions", {}, false, true)
    for k, v in pairs(CAMI.GetPrivileges()) do
        if ( !permissions[k] ) then
            permissions[k] = {}
        end

        if ( table.HasValue(permissions[k], data.Name) ) then
            table.RemoveByValue(permissions[k], data.Name)
        end

        if ( v.MinAccess == "user" ) then
            table.insert(permissions[k], data.Name)
        end

        if ( v.MinAccess == "admin" and ( data.Name == "admin" or data.Inherits == "admin" ) ) then
            table.insert(permissions[k], data.Name)
        end

        if ( v.MinAccess == "superadmin" and ( data.Name == "superadmin" or data.Inherits == "superadmin" ) ) then
            table.insert(permissions[k], data.Name)
        end
    end

    ix.data.Set("usergroup_permissions", permissions, false, true)

    PLUGIN:SaveUserGroups()
    PLUGIN:SyncUserGroups()

    ply:NotifyLocalized("vanguard_usergroup_reset_all", usergroup)
end)