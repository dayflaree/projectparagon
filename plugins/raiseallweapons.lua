local PLUGIN = PLUGIN

PLUGIN.name = "Raise All Weapons"
PLUGIN.description = ""
PLUGIN.author = "Reece™"

PLUGIN.bypass = {
    ["ix_hands"] = true,
}

function PLUGIN:PlayerSwitchWeapon(ply, oldWep, newWep)
    if ( self.bypass[newWep:GetClass()] ) then
        return
    end

    if not ( IsValid(newWep) and newWep:GetClass() ) then
        return
    end

    ALWAYS_RAISED[newWep:GetClass()] = true
end