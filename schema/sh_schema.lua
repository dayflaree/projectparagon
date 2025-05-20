-- Schema info

Schema.name = "Project Paragon"
Schema.description = "SCP: Containment Breach Roleplay"
Schema.author = "day"

-- Schema includes

ix.util.Include("cl_schema.lua")
ix.util.Include("sv_schema.lua")
ix.util.IncludeDir("hooks")
ix.util.IncludeDir("meta")

-- Schema config

local config = {
    color = Color(255, 255, 255),
    music = "projectparagon/sfx/Music/menu.mp3",
    communityURL = "https://discord.gg/TrXY4sPcrJ",
    font = "Courier New",
    genericFont = "Courier New",
    intro = false,
    areaTickTime = 0.5,
    allowVoice = true,
    thirdperson = false,
    forceSmoothView = true,
    forceDisableAnimations = true,
    vignette = false,
    allowGlobalOOC = false,
    chatColor = Color(255, 217, 67),
    chatListenColor = Color(107, 193, 78),
    paSystemEnabled = true,
    allowBusiness = false,
    runRankHook = true,
    maxCharacters = 4,
    inventoryHeight = 2,
    inventoryWidth = 5,
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

player_manager.AddValidModel("MTF", "models/cpthazama/scp/ntf.mdl")
player_manager.AddValidHands("MTF", "models/player/thefunnymann/scp/ntf_arms.mdl", 0, "00000000")

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
