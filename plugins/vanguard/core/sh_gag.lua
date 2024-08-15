/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

function PLUGIN:PlayerIsGagged(ply)
    if ( !IsValid(ply) ) then return end

    local char = ply:GetCharacter()
    if ( !char ) then return end

    local gagTime = ply:GetData("gagTime", 0)
    if ( gagTime > os.time() ) then
        return true
    end

    if ( SERVER ) then
        ply:SetData("gagTime", 0)
        ply:SaveData()
    end

    return false
end

local PLAYER = FindMetaTable("Player")
function PLAYER:VanguardIsGagged()
    if ( !IsValid(self) ) then return end

    return PLUGIN:PlayerIsGagged(self)
end