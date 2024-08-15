/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

function PLUGIN:PlayerOOCTimeout(ply, minutes)
    if ( !IsValid(ply) ) then return end

    local char = ply:GetCharacter()
    if ( !char ) then return end

    if ( !minutes or minutes < 1 ) then
        minutes = 1
    end

    ply:SetData("ixOOCTimeout", os.time() + (minutes * 60))
    ply:SaveData()
end

function PLUGIN:PlayerUnOOCTimeout(ply)
    if ( !IsValid(ply) ) then return end

    local char = ply:GetCharacter()
    if ( !char ) then return end

    ply:SetData("ixOOCTimeout", 0)
    ply:SaveData()
end

local PLAYER = FindMetaTable("Player")

function PLAYER:VanguardOOCTimeout(minutes)
    if ( !IsValid(self) ) then return end

    PLUGIN:PlayerOOCTimeout(self, minutes)
end

function PLAYER:VanguardUnOOCTimeout()
    if ( !IsValid(self) ) then return end

    PLUGIN:PlayerUnOOCTimeout(self)
end