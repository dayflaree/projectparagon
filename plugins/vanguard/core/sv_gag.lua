/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

function PLUGIN:PlayerGag(ply, minutes)
    if ( !IsValid(ply) ) then return end

    local char = ply:GetCharacter()
    if ( !char ) then return end

    if ( !minutes or minutes < 1 ) then
        minutes = 1
    end

    ply:SetData("gagTime", os.time() + (minutes * 60))
    ply:SaveData()
end

function PLUGIN:PlayerUnGag(ply)
    if ( !IsValid(ply) ) then return end

    local char = ply:GetCharacter()
    if ( !char ) then return end

    ply:SetData("gagTime", 0)
    ply:SaveData()
end

local PLAYER = FindMetaTable("Player")

function PLAYER:VanguardGag(minutes)
    if ( !IsValid(self) ) then return end

    PLUGIN:PlayerGag(self, minutes)
end

function PLAYER:VanguardUnGag()
    if ( !IsValid(self) ) then return end

    PLUGIN:PlayerUnGag(self)
end