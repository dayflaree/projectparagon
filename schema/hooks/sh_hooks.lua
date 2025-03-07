function Schema:CanDrive()
    return false
end

function Schema:CanPlayerUseBusiness()
    return false
end

function Schema:CanPlayerJoinClass()
	return false
end

function Schema:PlayerBindPress(client, bind, pressed)
    if (bind:find("+zoom") and pressed) then
        return true
    end
end

function Schema:OnReloaded()
    if ( SERVER ) then
        if ( ( nextserverRefresh or 0 ) <= CurTime() ) then
            ix.log.AddRaw("Server has been refreshed!")

            for k, v in pairs(player.GetAll()) do
                v:ChatNotify("[Paragon] Server has been refreshed!")
                v:ConCommand("play", "projectparagon/gamesounds/scpcb/general/save1.ogg")
            end

            nextserverRefresh = CurTime() + 1
        end
    end

    if ( CLIENT ) then
        if ( ( nextclientRefresh or 0 ) <= CurTime() ) then
            for k, v in pairs(player.GetAll()) do
                ix.log.AddRaw("Client has been refreshed!")
                v:ChatNotify("[Paragon] Client has been refreshed!")
                RunConsoleCommand("play", "projectparagon/gamesounds/scpcb/general/save1.ogg")
            end

            nextclientRefresh = CurTime() + 1
        end
    end
end