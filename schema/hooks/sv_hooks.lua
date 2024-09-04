-- Here is where all serverside hooks should go.

function Schema:PostPlayerSay(client, chatType, message, anonymous)
    if ( chatType == "ic" ) then
        ix.log.Add(client, "chat", chatType and chatType:utf8upper() or "??", text or message)
    end
end

function Schema:CanPlayerThrowPunch()
    return false
end

function Schema:PlayerInteractItem(ply, action, item)
    if ( action == "take" ) then
        if ( item.interactSounds and istable(item.interactSounds) ) then
            ply:EmitSound(item.interactSounds[math.random(1, #item.interactSounds)])
        end
    end
end

function Schema:PlayerModelChanged(ply, model)
    if ( !IsValid(ply) or ply:IsBot() ) then return end

    ply:SetupHands()
end

function Schema:PlayerTick(ply)
    local char = ply:GetCharacter()
    if not ( IsValid(ply) and ply:Alive() and char ) then
        return
    end
    if not ( ( ply.ixNextBreath or 0 ) < CurTime() ) then
        return
    end
    if ( char:GetInventory():HasItem("face_gasmask", {["equip"] = true}) ) then
        ply:EmitSound("minerva/global/breathing2.mp3", 60, nil, 0.2)
        ply.ixNextBreath = CurTime() + math.random(4, 18)
    end
end
function Schema:PlayerSpray()
    return false
end
function Schema:PlayerSpawnRagdoll(ply)
    return ply:IsAdmin()
end
function Schema:PlayerSpawnSENT(ply)
    return ply:IsAdmin()
end
function Schema:PlayerSpawnSWEP(ply)
    return ply:IsAdmin()
end
function Schema:PlayerSpawnVehicle(ply)
    return ply:IsAdmin()
end

function Schema:PlayerCanHearPlayersVoice(listener, talker)
    for k, v in pairs(ents.FindByClass("ix_intercom")) do
        if ( talker:GetPos():DistToSqr(v:GetPos()) < 48440 ) then
            for a, b in pairs(ents.FindByClass("ix_intercomhear")) do
                if ( listener:GetPos():DistToSqr(b:GetPos()) < 100000 ) then
                    if ( v:GetEnabled() ) then
                        return true
                    end
                end
            end
		end
	end
end

function Schema:GetPlayerDeathSound(client)
    return end
end

function Schema:GetPlayerPainSound(client)
    return end
end