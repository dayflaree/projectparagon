local PLUGIN = PLUGIN

function PLUGIN:OnCharacterMenuCreated()
    net.Start("ixIntroMusic-StopMusic")
    net.SendToServer()
end

net.Receive("ixIntroMusic-StartCharacterMusic", function()
    if ( IsValid(ix.gui.characterMenu) ) then
        ix.gui.characterMenu:PlayMusic()
    end
end)