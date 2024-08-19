local PLAYER = FindMetaTable("Player")

function PLAYER:GetAccessLevel()
    local char = self:GetCharacter()
    if ( !char ) then return 0 end

    return char:GetAccessLevel()
end