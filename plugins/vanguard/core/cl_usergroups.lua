/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

PLUGIN.permissions = PLUGIN.permissions or {}

local receivedChunks = {}
local expectedChunks = 0

net.Receive("ixVanguardUsergroupsSync", function(len)
    // Check if we are receiving the total number of chunks first
    if ( expectedChunks == 0 ) then
        expectedChunks = net.ReadUInt(32)
        receivedChunks = {} // Reset received chunks table
        MsgC(Color(255, 255, 255), "[Vanguard] [Usergroups] Expecting " .. expectedChunks .. " chunks\n")
        return
    end

    // Receiving a chunk
    local chunkIndex = net.ReadUInt(32)
    local chunkSize = net.ReadUInt(32)
    if ( chunkSize > 8192 ) then // 8KB
        MsgC(Color(255, 0, 0), "[Vanguard] [Usergroups] Chunk size too large\n")
        return
    end

    local chunkData = net.ReadData(chunkSize)

    receivedChunks[chunkIndex] = chunkData
    MsgC(Color(255, 255, 0), "[Vanguard] [Usergroups] Received chunk " .. chunkIndex .. " of size " .. chunkSize .. "\n")

    // Check if all chunks are received
    if ( table.Count(receivedChunks) == expectedChunks ) then
        MsgC(Color(0, 255, 0), "[Vanguard] [Usergroups] All chunks received\n")

        // Reassemble the full data
        local fullData = table.concat(receivedChunks)
        local decompressedData = util.Decompress(fullData)
        if ( !decompressedData ) then
            MsgC(Color(255, 0, 0), "[Vanguard] [Usergroups] Failed to decompress data\n")
            return
        end

        local combined = util.JSONToTable(decompressedData)
        if ( !combined ) then
            MsgC(Color(255, 0, 0), "[Vanguard] [Usergroups] Failed to convert JSON to table\n")
            return
        end

        // Update the PLUGIN usergroups and permissions
        local usergroups = combined[1]
        local permissions = combined[2]

        for key, data in pairs(CAMI.GetUsergroups()) do
            CAMI.UnregisterUsergroup(data.Name)
        end

        for key, data in pairs(usergroups) do
            CAMI.RegisterUsergroup(data, "Vanguard")
        end

        PLUGIN.permissions = permissions

        // Reset for the next sync
        expectedChunks = 0
        receivedChunks = {}
    end

    // Update the panel if it is valid
    if ( IsValid(ix.gui.vanguardUsergroups) and IsValid(ix.gui.vanguardUsergroups.scroller) ) then
        ix.gui.vanguardUsergroupsLastScroll = ix.gui.vanguardUsergroups.scroller:GetVBar():GetScroll()
        ix.gui.vanguardUsergroups:Populate()
    end
end)