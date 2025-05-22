FACTION.name = "Class D Personnel"
FACTION.color = Color(170, 112, 53)
FACTION.isDefault = true
FACTION.models = {"models/cpthazama/scp/dclass.mdl"}
FACTION.introMusic = "projectparagon/sfx/Music/Intro.ogg"

FACTION.defaultHealth = 100
FACTION.maxHealth = 100
FACTION.defaultArmor = 100
FACTION.maxArmor = 200

FACTION.radioConfig = {
    breathingLoop = {
        enabled = false,
    }
}

function FACTION:OnCharacterCreated(ply, char)
    char:SetName("D-"..Schema:ZeroNumber(math.random(1, 9999), 4).." "..char:GetName())
    char:SetRank(RANK_CLASSD_STANDARD)
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

FACTION_CLASSD = FACTION.index
