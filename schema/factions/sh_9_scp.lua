FACTION.name = "Anomaly"
FACTION.color = Color(173, 40, 40)
FACTION.isDefault = true
FACTION.models = {"models/cpthazama/scp/173.mdl"}

function FACTION:OnSpawn(client)
    local char = client:GetCharacter()
    if not char then return end

    local steamID = client:SteamID()

    -- SteamID-to-Class map
    local classAssignments = {
        ["STEAM_0:1:80008500"] = CLASS_SCP173,
    }

    local assignedClass = classAssignments[steamID]

    if assignedClass then
        char:SetClass(assignedClass)
    end
end

FACTION_SCP = FACTION.index