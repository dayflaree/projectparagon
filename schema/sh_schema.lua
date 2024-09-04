-- Schema info

Schema.name = "Project Paragon"
Schema.description = "SCP: Containment Breach Roleplay"
Schema.author = "90"

-- Schema includes

ix.util.Include("cl_schema.lua")
ix.util.Include("sv_schema.lua")
ix.util.IncludeDir("hooks")
ix.util.IncludeDir("meta")

-- Schema config

local config = {
    color = Color(255, 255, 255),
    music = "projectparagon/ui/paragon_menu.mp3",
    communityURL = "https://discord.gg/nUBpfxDPee",
    font = "Courier New",
    genericFont = "Courier New",
    intro = false,
    areaTickTime = 0,
    allowVoice = true,
    thirdperson = false,
    vignette = false,
    allowGlobalOOC = false,
    chatColor = Color(255, 217, 67),
    chatListenColor = Color(107, 193, 78),
    maxCharacters = 4,
    inventoryHeight = 2,
    inventoryWidth = 4,
    animMaxRate = 1,
    walkSpeed = 80,
    runSpeed = 180,
    staminaDrain = 2.6,
    staminaRegeneration = 2,
}

for k, v in pairs(config) do
    ix.config.SetDefault(k, v)
    ix.config.ForceSet(k, v)
end

-- Schema playermodels

player_manager.AddValidModel("Passive", "models/projectparagon/classd/classd.mdl")
player_manager.AddValidModel("Passive", "models/projectparagon/clerk/clerk.mdl")
player_manager.AddValidHands("Passive", "models/projectparagon/classd/d_class_player_vm.mdl", 0, "00000000")
player_manager.AddValidModel("Combatant", "models/projectparagon/guard/guard.mdl")
player_manager.AddValidModel("Combatant", "models/projectparagon/guard2/guard2.mdl")
player_manager.AddValidModel("Combatant", "models/cpthazama/scp/ntf.mdl")
player_manager.AddValidModel("Combatant", "models/projectparagon/chaos/chaos.mdl")
player_manager.AddValidHands("Combatant", "models/projectparagon/scp_combatant_vm.mdl", 0, "00000000")
player_manager.AddValidModel("SCP-049", "models/cpthazama/scp/049.mdl")
player_manager.AddValidHands("SCP-049", "models/scp049upgrade/weapons/c_arms_scp049_upgrade.mdl", 0, "00000000")

-- Schema flags

ix.flag.Add("S", "Access to the spawn menu.")
ix.flag.Add("s", "Access to the context menu.")

-- Here is where all shared functions should go.

function Schema:ZeroNumber(number, length)
    local amount = math.max(0, length - string.len(number))
    return string.rep("0", amount)..tostring(number)
end

function Schema:IsInRoom(ent, target)
    local tracedata = {}
    tracedata.start = ent:GetPos()
    tracedata.endpos = target:GetPos()
    local trace = util.TraceLine(tracedata)

    return not trace.HitWorld
end

function Schema:InitPostEntity()
    local toolgun = weapons.GetStored("gmod_tool")

    if not ( istable(toolgun) ) then
        return
    end

    function toolgun:DoShootEffect(hitpos, hitnorm, ent, physbone, predicted)
        self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
        self:GetOwner():SetAnimation(PLAYER_ATTACK1)

        return false
    end
end
