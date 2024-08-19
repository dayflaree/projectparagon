local PLUGIN = PLUGIN

function PLUGIN:GetLevel(ent)
    return ent:GetNetVar("level", 0)
end