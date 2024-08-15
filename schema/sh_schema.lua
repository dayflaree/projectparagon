-- Schema info

Schema.name = "Project Paragon"
Schema.description = ""
Schema.author = ""

-- Schema includes

ix.util.Include("cl_schema.lua")
ix.util.Include("sv_schema.lua")
ix.util.IncludeDir("hooks")
ix.util.IncludeDir("meta")

-- Schema config

ix.config.SetDefault("color", Color(255, 255, 255))
ix.config.SetDefault("walkSpeed", 80)
ix.config.SetDefault("runSpeed", 180)
ix.config.SetDefault("music", "projectparagon/ui/paragon_menu.mp3")
ix.config.SetDefault("vignette", false)
ix.config.SetDefault("communityURL", "https://discord.gg/nUBpfxDPee")
ix.config.SetDefault("intro", false)
ix.config.SetDefault("thirdperson", false)
ix.config.SetDefault("allowVoice", true)
ix.config.Set("color", Color(255, 255, 255))
ix.config.Set("walkSpeed", 100)
ix.config.Set("runSpeed", 200)
ix.config.Set("music", "projectparagon/ui/paragon_menu.mp3")
ix.config.Set("vignette", false)
ix.config.Set("communityURL", "https://discord.gg/nUBpfxDPee")
ix.config.Set("intro", false)
ix.config.Set("thirdperson", false)
ix.config.Set("allowVoice", true)

-- Schema playermodels
player_manager.AddValidModel("Passive", "models/cpthazama/scp/dclass.mdl")
player_manager.AddValidModel("Passive", "models/cpthazama/scp/scientist.mdl")
player_manager.AddValidModel("Passive", "models/cpthazama/scp/janitor.mdl")
player_manager.AddValidHands("Passive", "models/duck/player/d_class_player_vm.mdl", 0, "00000000")

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
