CLASS.name = "SCP-173"
CLASS.faction = FACTION_SCP
CLASS.isDefault = false

CLASS.OnSet = function(client)
    if not IsValid(client) or not client.GetCharacter then return end

    local char = client:GetCharacter()
    if char then
        char:SetModel("models/cpthazama/scp/173.mdl")
        char:SetName("SCP-173")
    end
end

CLASS.onCanSpawn = function(client)
    return client:SteamID() == "STEAM_0:1:80008500"
end

CLASS_SCP_173 = CLASS.index
