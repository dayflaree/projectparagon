local ITEM = ix.meta.item or {}

function ITEM:MakeSalvageable(items, sounds, attribute, attribBoost, effect)
    self.functions.salvage = {
        name = "Salvage",
        icon = "icon16/wrench.png",
        OnRun = function(item)
            local ply = item.player
            local char = ply:GetCharacter()

            for k, v in ipairs(items) do
                if not ( char:GetInventory():Add(v) ) then
                    ix.item.Spawn(v, ply, nil, angle_zero)
                end
            end

            if ( sounds ) then
                ply:EmitSound(sounds[math.random(1, #sounds)])
            else
                ply:EmitSound("physics/plastic/plastic_barrel_break"..math.random(1, 5)..".wav")
            end

            if ( attribute ) then
                char:UpdateAttrib(attribute, attribBoost or 0.1)
            end

            if ( effect ) then
                local pos = ply:EyePos() + ply:GetAimVector() * 8

                local effectData = EffectData()
                effectData:SetStart(pos)
                effectData:SetOrigin(pos)
                effectData:SetScale(1)
                
                util.Effect(effect, effectData)
            end

            local stacks = item:GetData("stacks", 1)
            local quantity = item:GetData("quantity", 1)
            if ( quantity > 1 ) then
                item:SetData("quantity", quantity - 1)
            elseif ( stacks > 1 ) then
                item:SetData("stacks", stacks - 1)
            else
                item:Remove()
            end

            return false
        end,
        OnCanRun = function(item)
            local ply = item.player

            local bEquiped = item:GetData("equip", false)
            if ( bEquiped ) then
                return false
            end

            if ( timer.Exists("ixAct"..ply:UniqueID()) ) then
                return false
            end

            return true
        end,
    }
end