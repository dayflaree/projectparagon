FACTION.name = "Scientific Department"
FACTION.color = Color(255, 166, 166)
FACTION.isDefault = false
FACTION.models = {"models/cpthazama/scp/scientist.mdl"}

FACTION.defaultHealth = 100
FACTION.maxHealth = 100
FACTION.defaultArmor = 100
FACTION.maxArmor = 200

function FACTION:OnCharacterCreated(ply, char)
    char:SetName("Dr. "..char:GetName())
    char:SetRank(RANK_SCIENTIFIC_ASSISTANT)
    char:SetData("skin", math.random(0, 2))
end

function FACTION:OnSpawn(client)
    timer.Simple(0.1, function()
        if not IsValid(client) then return end

        client:SetHealth(math.min(self.defaultHealth or 100, self.maxHealth or 100))
        client:SetMaxHealth(self.maxHealth or 100)

        client:SetArmor(math.min(self.defaultArmor or 0, self.maxArmor or 100))
    end)
end

FACTION_SCIENTIFIC = FACTION.index
