/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

util.AddNetworkString("ixVanguardLogsChat")
function PLUGIN:SendChatLog(...)
    if ( !ix.config.Get("chatLogs", true) ) then
        return
    end

    local players = {}
    for _, v in player.Iterator() do
        if ( !IsValid(v) ) then
            continue
        end

        if ( ix.config.Get("chatLogsAdminOnly", true) and !CAMI.PlayerHasAccess(v, "Helix - Vanguard Logs - View", nil) ) then
            continue
        end

        players[#players + 1] = v
    end

    if ( #players == 0 ) then
        return
    end

    local args = {}
    args[#args + 1] = ix.config.Get("vanguardColor")
    args[#args + 1] = "[VANGUARD] "

    args[#args + 1] = Color(255, 255, 255)
    
    for _, v in ipairs({...}) do
        args[#args + 1] = v
    end

    for _, v in ipairs(players) do
        net.Start("ixVanguardLogsChat")
            net.WriteTable(args)
        net.Send(v)
    end
end

util.AddNetworkString("ixVanguardLogsSync")
function PLUGIN:SyncLogs(delay, players)
    if ( delay ) then
        timer.Simple(delay, function()
            self:SyncLogs()
        end)
        
        return
    end

    if ( !players ) then
        players = {}
        for _, v in player.Iterator() do
            if ( !IsValid(v) ) then
                continue
            end

            if ( !CAMI.PlayerHasAccess(v, "Helix - Vanguard Logs - View", nil) ) then
                continue
            end
            
            players[#players + 1] = v
        end

        if ( #players == 0 ) then
            return
        end
    end
    
    local logs = {}
    local path = "helix/logs/" .. os.date("%x"):gsub("/", "-") .. ".txt"
    for _, v in ipairs(file.Find(path, "DATA")) do
        local content = file.Read(path, "DATA")
        local lines = {}
        for _, line in ipairs(string.Explode("\n", content)) do
            if ( line == "" ) then
                continue
            end

            line = string.Replace(line, "    ", " ")
            line = string.Replace(line, "]", "] ")

            lines[#lines + 1] = line
        end

        local count = 0
        local pages = 0
        for _, line in SortedPairs(lines, true) do
            logs[#logs + 1] = {line = line, page = pages}

            count = count + 1

            if ( count >= ix.config.Get("logsPerPage", 150) ) then
                count = 0
                pages = pages + 1
            end
        end
    end

    // Convert logs to JSON and compress
    logs = util.TableToJSON(logs)
    logs = util.Compress(logs)
    
    local totalLength = #logs
    local chunkSize = 8192 // 8KB
    local numChunks = math.ceil(totalLength / chunkSize)

    // Send the number of chunks to the client first
    net.Start("ixVanguardLogsSync")
        net.WriteUInt(numChunks, 32)
    net.Send(players)

    // Function to send each chunk
    local function SendChunk(chunkIndex)
        local startByte = (chunkIndex - 1) * chunkSize + 1
        local endByte = math.min(chunkIndex * chunkSize, totalLength)
        local chunkData = string.sub(logs, startByte, endByte)

        net.Start("ixVanguardLogsSync")
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

util.AddNetworkString("ixVanguardRequestLogs")
net.Receive("ixVanguardRequestLogs", function(_, ply)
    if ( !CAMI.PlayerHasAccess(ply, "Helix - Vanguard Logs - View", nil) ) then
        return
    end

    PLUGIN:SyncLogs(nil, ply)
end)