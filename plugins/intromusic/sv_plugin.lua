local PLUGIN = PLUGIN

util.AddNetworkString("ixIntroMusic-StartCharacterMusic")
util.AddNetworkString("ixIntroMusic-StopMusic")

function PLUGIN:PlayerLoadedCharacter(ply, char, oldChar)
    local music = self.introMusic
    ply:ConCommand('play "'..table.Random(music)..'"')
end

net.Receive("ixIntroMusic-StopMusic", function(len, ply)
    ply:ConCommand("stopsound")

    timer.Simple(1, function()
        if not ( IsValid(ply) ) then
            return
        end
        
        net.Start("ixIntroMusic-StartCharacterMusic")
        net.Send(ply)
    end)
end)