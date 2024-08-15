/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

function PLUGIN:CreateVanguardMenuButtons(tabs)
    local ply = LocalPlayer()
    tabs["gamemaster"] = {
        Create = function(info, container)
        end,
        Sections = {
            ["sequences"] = {
                Create = function(info, container)
                    vgui.Create("ixVanguardSequences", container)
                end,
            },
            ["sounds"] = {
                Create = function(info, container)
                    vgui.Create("ixVanguardSounds", container)
                end,
            },
        }
    }
end