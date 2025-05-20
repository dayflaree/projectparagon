
local PLUGIN = PLUGIN

PLUGIN.name = "Rank Whitelists"
PLUGIN.description = "Allows ranks to be obtainable with whitelists."
PLUGIN.author = "wowm0d"
PLUGIN.readme = [[
Allows ranks to be obtainable with whitelists.
Add the below funtion to any rank you wish to restrict to whitelists.

function CLASS:CanSwitchTo(client)
    return client:HasRankWhitelist(self.index)
end
]]

ix.lang.AddTable("english", {
    cmdPlyUnRankWhitelist = "Disallows someone to change to a specific rank within a faction.",
    cmdPlyRankWhitelist = "Allows someone to change to a specific rank within a faction.",
    rankwhitelist = "%s has whitelisted %s for the %s rank.",
    unrankwhitelist = "%s has unwhitelisted %s from the %s rank."
})

local playerMeta = FindMetaTable("Player")

function playerMeta:HasRankWhitelist(rank)
    local data = ix.rank.list[rank]

    if (data) then
        if (data.isDefault) then
            return true
        end

        local clientData = self:GetData("rankWhitelists", {})

        return clientData[Schema.folder] and clientData[Schema.folder][data.uniqueID]
    end

    return false
end

if (SERVER) then
    function playerMeta:SetRankWhitelisted(rank, whitelisted)
        if (whitelisted != true) then
            whitelisted = nil
        end

        local data = ix.rank.list[rank]

        if (data) then
            local rankWhitelists = self:GetData("rankWhitelists", {})
            rankWhitelists[Schema.folder] = rankWhitelists[Schema.folder] or {}
            rankWhitelists[Schema.folder][data.uniqueID] = whitelisted

            self:SetData("rankWhitelists", rankWhitelists)
            self:SaveData()

            return true
        end

        return false
    end
end

do
    local COMMAND = {}
    COMMAND.arguments = {ix.type.player, ix.type.text}
    COMMAND.superAdminOnly = true
    COMMAND.privilege = "Manage Character Whitelist"
    COMMAND.description = "@cmdPlyRankWhitelist"

    function COMMAND:OnRun(client, target, name)
        if (name == "") then
            return "@invalidArg", 2
        end

        local rank = ix.rank.list[name]

        if (!rank) then
            for _, v in ipairs(ix.rank.list) do
                if (ix.util.StringMatches(L(v.name, client), name) or ix.util.StringMatches(v.uniqueID, name)) or ix.util.StringMatches(tostring(v.index), name) then
                    rank = v

                    break
                end
            end
        end

        if (rank) then
            if (target:SetRankWhitelisted(rank.index, true)) then
                for _, v in player.Iterator() do
                    v:NotifyLocalized("rankwhitelist", client:GetName(), target:GetName(), L(rank.name, v))
                end
            end
        else
            return "@invalidRank"
        end
    end

    ix.command.Add("PlyRankWhitelist", COMMAND)
end

do
    local COMMAND = {}
    COMMAND.arguments = {ix.type.string, ix.type.text}
    COMMAND.superAdminOnly = true
    COMMAND.privilege = "Manage Character Whitelist"
    COMMAND.description = "@cmdPlyUnRankWhitelist"

    function COMMAND:OnRun(client, target, name)
        if (name == "") then
            return "@invalidArg", 2
        end

        local rank = ix.rank.list[name]

        if (!rank) then
            for _, v in ipairs(ix.rank.list) do
                if (ix.util.StringMatches(L(v.name, client), name) or ix.util.StringMatches(v.uniqueID, name)) or ix.util.StringMatches(tostring(v.index), name) then
                    rank = v

                    break
                end
            end
        end

        if (rank) then
            local targetPlayer = ix.util.FindPlayer(target)

            if (IsValid(targetPlayer) and targetPlayer:SetRankWhitelisted(rank.index, false)) then
                for _, v in player.Iterator() do
                    v:NotifyLocalized("unrankwhitelist", client:GetName(), targetPlayer:GetName(), L(rank.name, v))
                end
            else
                local steamID64 = util.SteamIDTo64(target)
                local query = mysql:Select("ix_players")
                    query:Select("data")
                    query:Where("steamid", steamID64)
                    query:Limit(1)
                    query:Callback(function(result)
                        if (istable(result) and #result > 0) then
                            local data = util.JSONToTable(result[1].data or "[]")
                            local whitelists = data.rankWhitelists and data["rankWhitelists"][Schema.folder]

                            if (whitelists and whitelists[rank.uniqueID]) then
                                whitelists[rank.uniqueID] = nil
                                data["rankWhitelists"][Schema.folder] = whitelists

                                local updateQuery = mysql:Update("ix_players")
                                    updateQuery:Update("data", util.TableToJSON(data))
                                    updateQuery:Where("steamid", steamID64)
                                updateQuery:Execute()

                                for _, v in player.Iterator() do
                                    v:NotifyLocalized("unrankwhitelist", client:GetName(), target, L(rank.name, v))
                                end
                            end
                        end
                    end)
                query:Execute()
            end
        else
            return "@invalidRank"
        end
    end

    ix.command.Add("PlyUnRankWhitelist", COMMAND)
end
