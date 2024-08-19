// Schema info

Schema.name = "Project Paragon"
Schema.description = ""
Schema.author = ""

// Schema includes

ix.util.Include("cl_schema.lua")
ix.util.Include("sv_schema.lua")
ix.util.IncludeDir("hooks")
ix.util.IncludeDir("meta")

// Schema config

// Maximize the animation rate, for example running and walking.
ANIM_MAX_RATE = 1.0

local config = {
    allowVoice = true,
    areaTickTime = 0,
    color = Color(255, 255, 255),
    communityURL = "https://discord.gg/nUBpfxDPee",
    intro = false,
    inventoryHeight = 2,
    inventoryWidth = 4,
    music = "projectparagon/ui/paragon_menu.mp3",
    runSpeed = 180,
    staminaDrain = 4,
    staminaRegeneration = 2,
    thirdperson = false,
    vignette = false,
    walkSpeed = 80
}

for k, v in pairs(config) do
    ix.config.SetDefault(k, v)
    ix.config.ForceSet(k, v)
end

// Schema playermodels
player_manager.AddValidModel("Passive", "models/cpthazama/scp/dclass.mdl")
player_manager.AddValidModel("Passive", "models/cpthazama/scp/scientist.mdl")
player_manager.AddValidModel("Passive", "models/cpthazama/scp/janitor.mdl")
player_manager.AddValidHands("Passive", "models/duck/player/d_class_player_vm.mdl", 0, "00000000")

player_manager.AddValidModel("Combatant", "models/cpthazama/scp/guard.mdl")
player_manager.AddValidModel("Combatant", "models/cpthazama/scp/ntf.mdl")
player_manager.AddValidModel("Combatant", "models/cpthazama/scp/chaos.mdl")
player_manager.AddValidModel("Combatant", "models/cpthazama/scp/sneguard.mdl")
player_manager.AddValidHands("Combatant", "models/projectparagon/scp_combatant_vm.mdl", 0, "00000000")

player_manager.AddValidModel("SCP-049", "models/cpthazama/scp/049.mdl")
player_manager.AddValidHands("SCP-049", "models/scp049upgrade/weapons/c_arms_scp049_upgrade.mdl", 0, "00000000")

// Schema flags

ix.flag.Add("S", "Access to the spawn menu.")
ix.flag.Add("s", "Access to the context menu.")

// Here is where all shared functions should go.

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
