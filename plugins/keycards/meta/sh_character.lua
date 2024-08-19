local PLUGIN = PLUGIN

local CHAR = ix.meta.character

function CHAR:GetAccessLevel()
    local inventory = self:GetInventory()
    if ( !inventory ) then return 0 end

    for key, level in pairs(PLUGIN.accessLevels) do
        if ( inventory:HasItem(key) ) then
            return level
        end
    end

    return 0
end