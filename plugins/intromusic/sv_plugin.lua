local PLUGIN = PLUGIN

util.AddNetworkString("ixIntroMusic-StartCharacterMusic")
util.AddNetworkString("ixIntroMusic-StopMusic")

function PLUGIN:PlayerLoadedCharacter(ply, char, oldChar)
    if not (IsValid(ply) and ply:IsPlayer() and char) then return end

    local factionIndex = char:GetFaction()
    if not factionIndex then return end

    local factionData = ix.faction.indices[factionIndex]

    if (factionData and factionData.introMusic) then
        local musicPathToPlay

        if (type(factionData.introMusic) == "table") then
            if (#factionData.introMusic > 0) then
                musicPathToPlay = table.Random(factionData.introMusic)
            end
        elseif (type(factionData.introMusic) == "string" and factionData.introMusic ~= "") then
            musicPathToPlay = factionData.introMusic
        end

        if (musicPathToPlay) then
            ply:ConCommand("stopsound")
            ply:ConCommand('play "' .. musicPathToPlay .. '"')
        end
    end
end

net.Receive("ixIntroMusic-StopMusic", function(len, ply)
    if not IsValid(ply) then return end

    ply:ConCommand("stopsound")

    timer.Simple(1, function()
        if not ( IsValid(ply) ) then
            return
        end

        net.Start("ixIntroMusic-StartCharacterMusic")
        net.Send(ply)
    end)
end)