local PLUGIN = PLUGIN

PLUGIN.name = "Remove Keys"
PLUGIN.author = "Zenith"
PLUGIN.description = "Removes the keys."

function PLUGIN:PostPlayerLoadout(ply)
    timer.Simple(0.1, function()
        ply:StripWeapon("ix_keys")
    end)
end