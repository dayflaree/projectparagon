/*
    © 2024 Minerva Servers do not share, re-distribute or modify
    without permission of its author (riggs9162@gmx.de).
*/

local PLUGIN = PLUGIN

function PLUGIN:AddMenuOption(menu, name, icon, callback)
    local button = menu:AddOption(name, function()
        callback()
    end)

    button:SetImage(icon)

    return button
end

function PLUGIN:AddMenuOptions(menu, name, icon, options)
    local subMenu, subMenuParent = menu:AddSubMenu(name)
    subMenuParent:SetImage(icon)

    for k, v in SortedPairs(options) do
        local button = subMenu:AddOption(k, v)

        button:SetImage(icon)
    end

    return subMenu
end