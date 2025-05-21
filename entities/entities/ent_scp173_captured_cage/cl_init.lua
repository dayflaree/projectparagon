include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    -- Optional: Draw owner's name or some status above the cage
    -- local owner = self:GetOwnerPlayer()
    -- if IsValid(owner) then
    --     local pos = self:GetPos() + Vector(0,0, self:OBBMaxs().z + 10)
    --     local ang = LocalPlayer():EyeAngles()
    --     ang.p = 0; ang.r = 0;

    --     cam.Start3D2D(pos, ang, 0.1)
    --         draw.SimpleTextOutlined(owner:Name().."'s Captured SCP-173", "DermaDefaultBold", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
    --     cam.End3D2D()
    -- end
end

-- If you need to react to networked var changes on client:
-- function ENT:OnOwnerPlayerChanged(oldVal, newVal) end
-- function ENT:OnCapturedSCPChanged(oldVal, newVal) end

-- File: gamemodes/projectparagon/gamemode/core/cl_init.lua

-- ... (other client-side initializations for your schema) ...

-- ==============================================================================
-- Custom Use Logic for SCP-173 Cage
-- ==============================================================================
local lastCageUseAttempt = 0
local cageUseCooldown = 0.2 -- Reduced cooldown for easier testing, can increase later

hook.Add("KeyPress", "Paragon_CustomUse_SCP173Cage", function(ply, key)
    -- DEBUG 1: Is the KeyPress hook even firing for IN_USE?
    if key == IN_USE then
        print("[CAGE DEBUG CLIENT] IN_USE KeyPress detected.")
    end

    if key ~= IN_USE then return end
    if not IsValid(ply) or ply ~= LocalPlayer() or not ply:Alive() then return end

    -- DEBUG 2: Are we passing initial checks?
    print("[CAGE DEBUG CLIENT] Passed initial player checks.")

    if CurTime() < lastCageUseAttempt + cageUseCooldown then
        -- DEBUG 3: Are we being blocked by cooldown?
        print("[CAGE DEBUG CLIENT] Use attempt blocked by cooldown. Remaining:", (lastCageUseAttempt + cageUseCooldown) - CurTime())
        return
    end
    print("[CAGE DEBUG CLIENT] Cooldown check passed.")

    local eyePos = ply:EyePos()
    local aimVec = ply:GetAimVector()
    local traceDist = 120 -- Increased slightly for more generous range
    local traceEndPos = eyePos + (aimVec * traceDist)

    print(string.format("[CAGE DEBUG CLIENT] Tracing from %s to %s", tostring(eyePos), tostring(traceEndPos)))

    local foundCage = nil

    -- Primary check: TraceLine
    local tr = util.TraceLine({
        start = eyePos,
        endpos = traceEndPos,
        filter = ply,
        mask = MASK_SHOT_HULL -- This mask typically hits entities with collision models.
                             -- For SOLID_NONE, it's unlikely to hit directly unless it has some invisible hull for traces.
    })

    if IsValid(tr.Entity) then
        print(string.format("[CAGE DEBUG CLIENT] TraceLine hit entity: %s (Class: %s)", tostring(tr.Entity), tr.Entity:GetClass()))
        if tr.Entity:GetClass() == "ent_scp173_captured_cage" then
            foundCage = tr.Entity
            print("[CAGE DEBUG CLIENT] TraceLine found the cage!")
        end
    else
        print("[CAGE DEBUG CLIENT] TraceLine hit nothing or invalid entity.")
    end

    -- Secondary check: FindInSphere (if TraceLine didn't find it)
    if not IsValid(foundCage) then
        print("[CAGE DEBUG CLIENT] TraceLine failed, trying FindInSphere...")
        -- Check in a sphere around a point slightly in front of the player, along their aim vector
        local sphereCheckPos = eyePos + (aimVec * (traceDist * 0.6)) -- Check a bit closer than max trace
        local checkRadius = 50 -- Increased radius: How close the cage's origin needs to be to the sphereCheckPos
        print(string.format("[CAGE DEBUG CLIENT] FindInSphere at %s with radius %s", tostring(sphereCheckPos), checkRadius))

        local entitiesInSphere = ents.FindInSphere(sphereCheckPos, checkRadius)
        print(string.format("[CAGE DEBUG CLIENT] Found %d entities in sphere.", #entitiesInSphere))

        for i, entInSphere in ipairs(entitiesInSphere) do
            print(string.format("[CAGE DEBUG CLIENT] Sphere Entity %d: %s (Class: %s)", i, tostring(entInSphere), entInSphere:GetClass()))
            if IsValid(entInSphere) and entInSphere:GetClass() == "ent_scp173_captured_cage" then
                print("[CAGE DEBUG CLIENT] Found a cage entity in sphere: ", tostring(entInSphere))
                -- Additional check: is this cage roughly where the player is looking?
                local toCage = (entInSphere:WorldSpaceCenter() - eyePos):GetNormalized()
                local dotProduct = aimVec:Dot(toCage)
                print(string.format("[CAGE DEBUG CLIENT] Dot product to sphere cage: %.2f", dotProduct))
                if dotProduct > 0.80 then -- Reasonably direct look (was 0.85)
                    foundCage = entInSphere
                    print("[CAGE DEBUG CLIENT] FindInSphere found AND validated the cage via dot product!")
                    break
                else
                    print("[CAGE DEBUG CLIENT] Cage in sphere, but dot product too low.")
                end
            end
        end
        if not IsValid(foundCage) then
             print("[CAGE DEBUG CLIENT] FindInSphere did not validate a cage.")
        end
    end


    if IsValid(foundCage) then
        print(string.format("[CAGE DEBUG CLIENT] Valid cage found: %s. Sending net message.", tostring(foundCage)))
        net.Start("SCP173_Cage_PlayerAttemptUse")
            net.WriteEntity(foundCage)
        net.SendToServer()
        print("[CAGE DEBUG CLIENT] Net message 'SCP173_Cage_PlayerAttemptUse' sent.")

        lastCageUseAttempt = CurTime()
    else
        -- DEBUG 4: If no cage was found by either method
        print("[CAGE DEBUG CLIENT] No valid cage found by either trace or sphere check.")
    end
end)
-- ==============================================================================