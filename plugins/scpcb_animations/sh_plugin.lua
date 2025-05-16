local PLUGIN = PLUGIN

PLUGIN.name = "SCP: Containment Breach Animations"
PLUGIN.author = "day"
PLUGIN.description = "Animations for original SCP CB models that work for Helix."
PLUGIN.sequences = {
    [ACT_SIGNAL_GROUP] = "gesture_rally",
    [ACT_SIGNAL_HALT] = "gesture_hold"
}

function PLUGIN:PlayerShouldTaunt(ply, act)
    local sequence = self.sequences[act]
    if ( !sequence ) then return end

    ply:ForceSequence(sequence)
end

// Foundation
local foundation_idlewalkruncrouch = {
    [ACT_MP_STAND_IDLE] = {"idle", "idle"},
    [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
    [ACT_MP_WALK] = {"walk", "walk"},
    [ACT_MP_CROUCHWALK] = {"walk", "walk"},
    [ACT_MP_RUN] = {"run", "run"},
    [ACT_LAND] = {ACT_RESET, ACT_RESET}
}

local hazmat_idlewalkruncrouch = {
    [ACT_MP_STAND_IDLE] = {"idle", "idle"},
    [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
    [ACT_MP_WALK] = {"walk2", "walk2"},
    [ACT_MP_CROUCHWALK] = {"walk2", "walk2"},
    [ACT_MP_RUN] = {"walk", "walk"},
    [ACT_LAND] = {ACT_RESET, ACT_RESET}
}

local combatant_idlewalkrun = {
    [ACT_MP_STAND_IDLE] = {"idle", "idle"},
    [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
    [ACT_MP_WALK] = {"walk", "walk"},
    [ACT_MP_CROUCHWALK] = {"walk", "walk"},
    [ACT_MP_RUN] = {"run", "run"},
    [ACT_LAND] = {ACT_RESET, ACT_RESET}
}

local combatant_idlewalkrunaim = {
    [ACT_MP_STAND_IDLE] = {"idle", "idle_aim_look"},
    [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
    [ACT_MP_WALK] = {"walk", "walk"},
    [ACT_MP_CROUCHWALK] = {"walk", "walk"},
    [ACT_MP_RUN] = {"run", "run"},
    [ACT_LAND] = {ACT_RESET, ACT_RESET}
}

// Foundation
ix.anim.foundation = {
    normal = foundation_idlewalkruncrouch,
    pistol = foundation_idlewalkruncrouch,
    smg = foundation_idlewalkruncrouch,
    shotgun = foundation_idlewalkruncrouch,
    grenade = foundation_idlewalkruncrouch,
    melee = foundation_idlewalkruncrouch,
    glide = ACT_IDLE,
}

// Hazmat
ix.anim.hazmat = {
    normal = hazmat_idlewalkruncrouch,
    pistol = hazmat_idlewalkruncrouch,
    smg = hazmat_idlewalkruncrouch,
    shotgun = hazmat_idlewalkruncrouch,
    grenade = hazmat_idlewalkruncrouch,
    melee = hazmat_idlewalkruncrouch,
    glide = ACT_IDLE,
}

ix.anim.SetModelClass("models/cpthazama/scp/dclass.mdl", "foundation")
ix.anim.SetModelClass("models/cpthazama/scp/janitor.mdl", "foundation")
ix.anim.SetModelClass("models/cpthazama/scp/doctor/doctor.mdl", "foundation")
ix.anim.SetModelClass("models/cpthazama/scp/scientist.mdl", "foundation")
ix.anim.SetModelClass("models/painkiller_76/sf2/clerk/clerk.mdl", "foundation")
ix.anim.SetModelClass("models/dughoo/one_more_please/scpcb_boxofhorrors/npc178_2.mdl", "hazmat")

// Combatant
ix.anim.combatant = {
    normal = combatant_idlewalkrunaim,
    pistol = combatant_idlewalkrunaim,
    smg = combatant_idlewalkrunaim,
    shotgun = combatant_idlewalkrunaim,
    grenade = combatant_idlewalkrun,
    melee = combatant_idlewalkrun,
    glide = ACT_IDLE,
}

ix.anim.SetModelClass("models/cpthazama/scp/chaos.mdl", "combatant")
ix.anim.SetModelClass("models/cpthazama/scp/chaosp90.mdl", "combatant")
ix.anim.SetModelClass("models/cpthazama/scp/guard.mdl", "combatant")
ix.anim.SetModelClass("models/cpthazama/scp/sneguard.mdl", "combatant")
ix.anim.SetModelClass("models/cpthazama/scp/lambda.mdl", "combatant")
ix.anim.SetModelClass("models/cpthazama/scp/ntf.mdl", "combatant")
ix.anim.SetModelClass("models/cpthazama/scp/nu.mdl", "combatant")
ix.anim.SetModelClass("models/cpthazama/scp/guard_old.mdl", "combatant")