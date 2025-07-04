
--[[--
Logging helper functions.

Predefined flags:
    FLAG_NORMAL
    FLAG_SUCCESS
    FLAG_WARNING
    FLAG_DANGER
    FLAG_SERVER
    FLAG_DEV
]]
-- @module ix.log

-- luacheck: globals FLAG_NORMAL FLAG_SUCCESS FLAG_WARNING FLAG_DANGER FLAG_SERVER FLAG_DEV
FLAG_NORMAL = 0
FLAG_SUCCESS = 1
FLAG_WARNING = 2
FLAG_DANGER = 3
FLAG_SERVER = 4
FLAG_DEV = 5

ix.log = ix.log or {}
ix.log.color = {
    [FLAG_NORMAL] = color_white,
    [FLAG_SUCCESS] = Color(0, 255, 0),
    [FLAG_WARNING] = Color(255, 255, 0),
    [FLAG_DANGER] = Color(255, 0, 0),
    [FLAG_SERVER] = Color(140, 140, 220),
    [FLAG_DEV] = Color(140, 140, 220),
}

CAMI.RegisterPrivilege({
    Name = "Helix - Logs",
    MinAccess = "admin"
})

local consoleColor = color_white

if (SERVER) then
    if (!ix.db) then
        include("sv_database.lua")
    end

    util.AddNetworkString("ixLogStream")

    function ix.log.LoadTables()
        ix.log.CallHandler("Load")
    end

    ix.log.types = ix.log.types or {}

    --- Adds a log type
    -- @realm server
    -- @string logType Log category
    -- @string format The string format that log messages should use
    -- @number flag Log level
    function ix.log.AddType(logType, format, flag)
        ix.log.types[logType] = {format = format, flag = flag}
    end

    function ix.log.Parse(client, logType, ...)
        local info = ix.log.types[logType]

        if (!info) then
            ErrorNoHalt("attempted to add entry to non-existent log type \"" .. tostring(logType) .. "\"")
            return
        end

        local text = info and info.format

        if (text) then
            if (isfunction(text)) then
                text = text(client, ...)
            end
        else
            text = -1
        end

        return text, info.flag
    end

    function ix.log.AddRaw(logString, bNoSave)
        CAMI.GetPlayersWithAccess("Helix - Logs", function(receivers)
            ix.log.Send(receivers, logString)
        end)

        MsgC(color_white, "[Paragon] ", Color(0, 255, 255), logString.."\n")
        -- Msg("[LOG] ", logString .. "\n")

        if (!bNoSave) then
            ix.log.CallHandler("Write", nil, logString)
        end
    end

    --- Add a log message
    -- @realm server
    -- @player client Player who instigated the log
    -- @string logType Log category
    -- @param ... Arguments to pass to the log
    function ix.log.Add(client, logType, ...)
        local logString, logFlag = ix.log.Parse(client, logType, ...)
        if (logString == -1) then return end

        CAMI.GetPlayersWithAccess("Helix - Logs", function(receivers)
            ix.log.Send(receivers, logString, logFlag)
        end)

        MsgC(color_white, "[Paragon] ", Color(0, 255, 255), logString.."\n")
        -- Msg("[LOG] ", logString .. "\n")

        ix.log.CallHandler("Write", client, logString, logFlag, logType, {...})
    end

    function ix.log.Send(client, logString, flag)
        net.Start("ixLogStream")
            net.WriteString(logString)
            net.WriteUInt(flag or 0, 4)
        net.Send(client)
    end

    ix.log.handlers = ix.log.handlers or {}
    function ix.log.CallHandler(event, ...)
        for _, v in pairs(ix.log.handlers) do
            if (isfunction(v[event])) then
                v[event](...)
            end
        end
    end

    function ix.log.RegisterHandler(name, data)
        data.name = string.gsub(name, "%s", "")
            name = name:lower()
        data.uniqueID = name

        ix.log.handlers[name] = data
    end

    do
        local HANDLER = {}

        function HANDLER.Load()
            file.CreateDir("helix/logs")
        end

        function HANDLER.Write(client, message)
            file.Append("helix/logs/" .. os.date("%x"):gsub("/", "-") .. ".txt", "[" .. os.date("%X") .. "]\t" .. message .. "\r\n")
        end

        ix.log.RegisterHandler("File", HANDLER)
    end
else
    function ix.log.AddRaw(logString)
        if (isstring(logString)) then
            MsgC(color_white, "[Paragon] ", Color(0, 255, 255), logString.."\n")
        end
    end
    
    net.Receive("ixLogStream", function(length)
        local logString = net.ReadString()
        local flag = net.ReadUInt(4)

        if (isstring(logString) and isnumber(flag)) then
            MsgC(color_white, "[Paragon] ", ix.log.color[flag], logString.."\n")

            -- MsgC(consoleColor, "[SERVER] ", ix.log.color[flag], logString .. "\n")
        end
    end)
end
