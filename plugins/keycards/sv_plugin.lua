local PLUGIN = PLUGIN

function PLUGIN:PlayerUse(ply, ent)
    local char = ply:GetCharacter()
    if ( !char ) then return end

    if ( ent:GetClass() != "func_button" ) then return end

    local level = self:GetLevel(ent)
    if ( !self:IsValidLevel(level) ) then return end

    if ( !ent.ixNextUse ) then
        ent.ixNextUse = 0
    end

    if ( !ply.ixNextUseMe ) then
        ply.ixNextUseMe = 0
    end

    if ( ent.ixNextUse > CurTime() ) then return false end
    ent.ixNextUse = CurTime() + 2

    local hasAccess = false
    if ( ply:GetAccessLevel() >= level ) then
        hasAccess = true
    end

    local trace = util.TraceLine({
        start = ply:EyePos(),
        endpos = ent:GetPos(),
        filter = ply
    })

    debugoverlay.Line(ply:EyePos(), ent:GetPos(), 1, hasAccess and Color(0, 255, 0) or Color(255, 0, 0))

    if ( hasAccess ) then
        EmitSound("scp/sfx/interact/keycarduse1.wav", trace.HitPos, ply:EntIndex())
        debugoverlay.Text(trace.HitPos, "Access Granted", 1)

        if ( ply.ixNextUseMe < CurTime() and self.messagesAllowed and #self.messagesAllowed > 0 ) then
            ix.chat.Send(ply, "me", self.messagesAllowed[math.random(1, #self.messagesAllowed)])
            ply.ixNextUseMe = CurTime() + 5
        end
    else
        EmitSound("scp/sfx/interact/keycarduse2.wav", trace.HitPos, ply:EntIndex())
        debugoverlay.Text(trace.HitPos, "Access Denied", 1)
    
        if ( ply.ixNextUseMe < CurTime() and self.messagesDenied and #self.messagesDenied > 0 ) then
            ix.chat.Send(ply, "me", self.messagesDenied[math.random(1, #self.messagesDenied)])
            ply.ixNextUseMe = CurTime() + 5
        end

        return false
    end
end

function PLUGIN:LoadData()
    for k, v in ipairs(ents.FindByClass("func_button")) do
        local level = ix.data.Get("doorlevels/" .. v:MapCreationID())
        if ( level ) then
            self:SetLevel(v, level)
        end
    end
end

function PLUGIN:GetLevel(ent)
    return ent:GetNetVar("level", 0) or ix.data.Get("doorlevels/" .. ent:MapCreationID())
end

function PLUGIN:SetLevel(ent, level)
    if ( !IsValid(ent) or ent:GetClass() != "func_button" ) then
        return false
    end

    if ( level == 0 ) then
        ent:SetNetVar("level", nil)

        file.CreateDir("helix/" .. engine.ActiveGamemode() .. "/" .. game.GetMap() .. "/doorlevels")
        file.Delete("helix/" .. engine.ActiveGamemode() .. "/" .. game.GetMap() .. "/doorlevels/" .. ent:MapCreationID() .. ".txt")

        local buttonPositions = {}
        for _, v in ipairs(ents.FindByClass("func_button")) do
            if (v:GetNetVar("level", 0) > 0) then
                buttonPositions[#buttonPositions + 1] = {v:GetPos(), v:GetNetVar("level", 0)}
            end
        end

        SetNetVar("buttonPositions", buttonPositions)

        return
    end

    if ( !self:IsValidLevel(level) ) then
        return false
    end

    ent:SetNetVar("level", level)

    file.CreateDir("helix/" .. engine.ActiveGamemode() .. "/" .. game.GetMap() .. "/doorlevels")
    ix.data.Set("doorlevels/" .. ent:MapCreationID(), level)

    local buttonPositions = {}
    for _, v in ipairs(ents.FindByClass("func_button")) do
        if (v:GetNetVar("level", 0) > 0) then
            buttonPositions[#buttonPositions + 1] = {v:GetPos(), v:GetNetVar("level", 0)}
        end
    end

    SetNetVar("buttonPositions", buttonPositions)
end