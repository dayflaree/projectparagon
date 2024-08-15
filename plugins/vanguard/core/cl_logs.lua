/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

net.Receive("ixVanguardLogsChat", function(len)
    local args = net.ReadTable()
    if ( !args ) then return end

    CHAT_CLASS = ix.chat.classes["vanguard_chat_staff"]
        chat.AddText(unpack(args))
    CHAT_CLASS = nil
end)

local receivedChunks = {}
local expectedChunks = 0

net.Receive("ixVanguardLogsSync", function(len)
    // Check if we are receiving the total number of chunks first
    if ( expectedChunks == 0 ) then
        expectedChunks = net.ReadUInt(32)
        receivedChunks = {} // Reset received chunks table
        MsgC(Color(255, 255, 255), "[Vanguard] [Logs] Expecting " .. expectedChunks .. " chunks\n")
        return
    end

    // Receiving a chunk
    local chunkIndex = net.ReadUInt(32)
    local chunkSize = net.ReadUInt(32)
    if ( chunkSize > 8192 ) then // 8KB
        MsgC(Color(255, 0, 0), "[Vanguard] [Logs] Chunk size too large\n")
        return
    end

    local chunkData = net.ReadData(chunkSize)

    receivedChunks[chunkIndex] = chunkData
    MsgC(Color(255, 255, 0), "[Vanguard] [Logs] Received chunk " .. chunkIndex .. " of size " .. chunkSize .. "\n")

    // Check if all chunks are received
    if ( table.Count(receivedChunks) == expectedChunks ) then
        MsgC(Color(0, 255, 0), "[Vanguard] [Logs] All chunks received\n")

        // Reassemble the full data
        local fullData = table.concat(receivedChunks)

        local decompressedData = util.Decompress(fullData)
        if ( !decompressedData ) then
            MsgC(Color(255, 0, 0), "[Vanguard] [Logs] Failed to decompress data\n")
            return
        end

        local logs = util.JSONToTable(decompressedData)
        if ( !logs ) then
            MsgC(Color(255, 0, 0), "[Vanguard] [Logs] Failed to convert JSON to table\n")
            return
        end

        // Update the PLUGIN logs
        if ( !PLUGIN.logs ) then
            PLUGIN.logs = {}
        end

        PLUGIN.logs = logs

        // Update the panel if it is valid
        local panel = ix.gui.vanguardLogs
        if ( IsValid(panel) ) then
            panel:PopulateLogs(panel.page, panel.searchEntry:GetValue())
        end

        // Reset for the next sync
        expectedChunks = 0
        receivedChunks = {}
    end
end)