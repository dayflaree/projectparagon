local PLUGIN = PLUGIN

PLUGIN.name = "Overwatch Shove"
PLUGIN.description = "A Command which gives the ability to knock players out and damage props with the /shove command."
PLUGIN.author = "Riggs, eon (bloodycop)"
PLUGIN.schema = "HL2 RP"
PLUGIN.license = [[
Copyright 2024 Riggs

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

ix.config.Add("shoveTime", 20, "How long should a character be unconscious after being knocked out?", nil, {
    data = {min = 5, max = 60},
})

ix.config.Add("shoveForce", 4500, "How much force should be applied to an object when it's shoved?", nil, {
    data = {min = 10, max = 10000},
})

ix.config.Add("shovePropDamage", 20, "How much damage should be dealt to a prop when it's shoved?", nil, {
    data = {min = 0, max = 100},
})

local animConfig = {
    ["citizen_male"] = {"meleeattack01", "meleeattack01"},
    ["citizen_female"] = {"meleeattack01", "meleeattack01"},
    ["metrocop"] = {"melee_gunhit", "melee_gunhit"},
    ["overwatch"] = {"melee_gunhit", "melee_kick"},
    ["player"] = {"seq_meleeattack01", "seq_meleeattack01"}
}

ix.command.Add("Shove", {
    description = "Shove someone with an animation.",
    OnRun = function(this, ply)
        if ( ply:IsWalking() or ply:IsRunning() or ply:IsRestricted() or !ply:OnGround() ) then
            return "@notNow"
        end

        local animClass = ix.anim.GetModelClass(ply:GetModel())
        local anim = animConfig[animClass]
        if ( !anim ) then return "@notNow" end

        local sequence = anim[1]
        if ( ply:GetAimVector().z < -0.05 ) then
            sequence = anim[2]
        end

        ply:SetLocalVelocity(vector_origin)
        ply:ForceSequence(sequence, nil)

        local data = {}

        ply:LagCompensation(true)
            timer.Simple(0.35, function()
                if ( !IsValid(ply) ) then return end

                data.start = ply:GetShootPos()
                data.endpos = data.start + ply:GetAimVector() * 64
                data.filter = ply
            end)
        ply:LagCompensation(false)

        timer.Simple(0.35, function()
            local target = util.TraceLine(data).Entity

            if ( IsValid(target) ) then
                if ( target:IsPlayer() and ply:IsCombine() ) then
                    target:SetVelocity(ply:GetAimVector() * 384)

                    timer.Simple(0.05, function()
                        ply:EmitSound("physics/body/body_medium_impact_hard6.wav", 50, math.random(95, 105), nil, CHAN_AUTO)
                        target:EmitSound("physics/body/body_medium_impact_hard6.wav", 50, math.random(95, 105), nil, CHAN_AUTO)
                        target:SetRagdolled(true, ix.config.Get("shoveTime", 20))
                    end)
                else
                    local damageInfo = DamageInfo()
                        damageInfo:SetDamage(ix.config.Get("shovePropDamage", 20))
                        damageInfo:SetDamageType(DMG_CLUB)
                        damageInfo:SetAttacker(ply)
                        damageInfo:SetInflictor(ply)
                        damageInfo:SetDamagePosition(target:GetPos())
                    target:TakeDamageInfo(damageInfo)

                    local dir = (target:GetPos() - ply:GetPos()):GetNormalized()

                    if ( IsValid(target:GetPhysicsObject()) ) then
                        print(target)
                        target:GetPhysicsObject():ApplyForceCenter(dir * ix.config.Get("shoveForce", 4500))
                    end

                    target:EmitSound("physics/body/body_medium_impact_hard6.wav", 75, 100, 1, CHAN_BODY)
                end
            end
        end)
    end,
})