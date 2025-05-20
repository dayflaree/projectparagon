FACTION.name = "Maintenance Department"
FACTION.color = Color(166, 175, 255)
FACTION.isDefault = false
FACTION.models = {"models/cpthazama/scp/janitor.mdl"}

FACTION.defaultHealth = 100
FACTION.maxHealth = 100
FACTION.defaultArmor = 100
FACTION.maxArmor = 200

function FACTION:OnCharacterCreated(ply, char)
    char:SetRank(RANK_MAINTENANCE_JANITOR)
    char:SetData("skin", math.random(0, 3))
end

function FACTION:OnSpawn(client)
    timer.Simple(0.1, function()
        if not IsValid(client) then return end

        client:SetHealth(math.min(self.defaultHealth or 100, self.maxHealth or 100))
        client:SetMaxHealth(self.maxHealth or 100)

        client:SetArmor(math.min(self.defaultArmor or 0, self.maxArmor or 100))
    end)
end

FACTION_MAINTENANCE = FACTION.index
