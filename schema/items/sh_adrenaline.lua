-- Item Statistics

ITEM.name = "Adrenaline"
ITEM.description = "A syringe containing a serum."
ITEM.category = "Medical Items"

-- Item Configuration

ITEM.model = "models/mishka/models/syringe.mdl"
ITEM.skin = 0

-- Item Inventory Size Configuration

ITEM.width = 1
ITEM.height = 1

-- Item Custom Configuration

ITEM.HealAmount = 15
ITEM.Volume = 10
ITEM.UseDuration = 5

local function ApplySpeedBoost(ply)
    if not IsValid(ply) or not ply:Alive() then return end

    local baseWalk = 100
    local baseRun = 200

    local speedMultiplier = math.Rand(1.2, 1.3)
    local duration = math.random(10, 15)

    if not ply.ixOriginalWalk then
        ply.ixOriginalWalk = ply:GetWalkSpeed()
    end
    if not ply.ixOriginalRun then
        ply.ixOriginalRun = ply:GetRunSpeed()
    end

    ply:SetWalkSpeed(baseWalk * speedMultiplier)
    ply:SetRunSpeed(baseRun * speedMultiplier)

    timer.Create("ixResetSpeed_" .. ply:EntIndex(), duration, 1, function()
        if IsValid(ply) then
            if ply.ixOriginalWalk then
                ply:SetWalkSpeed(ply.ixOriginalWalk)
                ply.ixOriginalWalk = nil
            end
            if ply.ixOriginalRun then
                ply:SetRunSpeed(ply.ixOriginalRun)
                ply.ixOriginalRun = nil
            end
        end
    end)
end

-- Item Functions

ITEM.functions.Apply = {
	name = "Use",
	OnCanRun = function(itemTable)
		local ply = itemTable.player
		if ( ply:IsValid() and ply:Health() < ply:GetMaxHealth() ) then
			return true
		else
			return false
		end
	end,
	OnRun = function(itemTable)
		local ply = itemTable.player
		ply:SetAction("Using " .. itemTable.name .. "...", itemTable.UseDuration or 5, function()
			if (IsValid(ply)) then
				ply:SetHealth(math.min(ply:Health() + itemTable.HealAmount, ply:GetMaxHealth()))
				ply:EmitSound("projectparagon/sfx/Interact/PickItem2.ogg", itemTable.Volume)
			end
		end)

		return true
	end
}