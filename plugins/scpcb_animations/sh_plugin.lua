local PLUGIN = PLUGIN

PLUGIN.name = "SCP: Containment Breach Animations"
PLUGIN.author = "90, Riggs"
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

local foundation_idlewalkruncrouch = {
    [ACT_MP_STAND_IDLE] = {"idle", "idle"},
    [ACT_MP_CROUCH_IDLE] = {"crouch", "crouch"},
    [ACT_MP_WALK] = {"walk", "walk"},
    [ACT_MP_CROUCHWALK] = {"crouch_walk", "crouch_walk"},
    [ACT_MP_RUN] = {"run", "run"},
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

// Foundation Passive
ix.anim.foundation = {
    normal = foundation_idlewalkruncrouch,
    pistol = foundation_idlewalkruncrouch,
    smg = foundation_idlewalkruncrouch,
    shotgun = foundation_idlewalkruncrouch,
    grenade = foundation_idlewalkruncrouch,
    melee = foundation_idlewalkruncrouch,
    glide = ACT_IDLE,
}

ix.anim.SetModelClass("models/painkiller_76/sf2/classd/classd.mdl", "foundation")

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

// SCP-035
ix.anim.scp035 = {
    normal = idlewalkrun,
    pistol = idlewalkrun,
    smg = idlewalkrun,
    shotgun = idlewalkrun,
    grenade = idlewalkrun,
    melee = idlewalkrun,
    glide = ACT_IDLE,
}

// SCP-049
ix.anim.scp049 = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"infect", "infect"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"infect", "infect"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"infect", "infect"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"infect", "infect"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"infect", "infect"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"infect", "infect"},
        [ACT_MP_WALK] = {"run", "run"},
        [ACT_MP_CROUCHWALK] = {"run", "run"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    glide = ACT_IDLE,
}

// SCP-096
ix.anim.scp096 = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"idle_sit", "idle_sit"},
        [ACT_MP_RUN] = {"runa", "runa"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"runa", "runa"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"runa", "runa"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"runa", "runa"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"runa", "runa"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"runa", "runa"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    glide = ACT_IDLE,
}

// SCP 106
ix.anim.scp106 = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walkslow", "walkslow"},
        [ACT_MP_CROUCHWALK] = {"idle_sit", "idle_sit"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walkslow", "walkslow"},
        [ACT_MP_CROUCHWALK] = {"idle_sit", "idle_sit"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walkslow", "walkslow"},
        [ACT_MP_CROUCHWALK] = {"idle_sit", "idle_sit"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walkslow", "walkslow"},
        [ACT_MP_CROUCHWALK] = {"idle_sit", "idle_sit"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walkslow", "walkslow"},
        [ACT_MP_CROUCHWALK] = {"idle_sit", "idle_sit"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET}
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle_sit", "idle_sit"},
        [ACT_MP_WALK] = {"walkslow", "walkslow"},
        [ACT_MP_CROUCHWALK] = {"idle_sit", "idle_sit"},
        [ACT_MP_RUN] = {"walk", "walk"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
        attack = "attack"
    },
    glide = ACT_IDLE,
}

// SCP-682
ix.anim.scp682 = {
    normal = idlewalkrun,
    pistol = idlewalkrun,
    smg = idlewalkrun,
    shotgun = idlewalkrun,
    grenade = idlewalkrun,
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
        attack = "attack"
    },
    glide = ACT_IDLE,
}

// SCP-939
ix.anim.scp939 = {
    normal = idlewalkrun,
    pistol = idlewalkrun,
    smg = idlewalkrun,
    shotgun = idlewalkrun,
    grenade = idlewalkrun,
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
        attack = "attack"
    },
    glide = ACT_IDLE,
}

// SCP-966
ix.anim.scp966 = {
    normal = idlewalkrun,
    pistol = idlewalkrun,
    smg = idlewalkrun,
    shotgun = idlewalkrun,
    grenade = idlewalkrun,
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
        attack = "attack_left"
    },
    glide = ACT_IDLE,
}

// SCP-1048
ix.anim.scp1048 = {
    normal = idlewalkrun,
    pistol = idlewalkrun,
    smg = idlewalkrun,
    shotgun = idlewalkrun,
    grenade = idlewalkrun,
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
    },
    glide = ACT_IDLE,
}

// SCP-1048-A
ix.anim.scp1048a = {
    normal = idlewalkrun,
    pistol = idlewalkrun,
    smg = idlewalkrun,
    shotgun = idlewalkrun,
    grenade = idlewalkrun,
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle", "idle"},
        [ACT_MP_CROUCH_IDLE] = {"idle", "idle"},
        [ACT_MP_WALK] = {"walk", "walk"},
        [ACT_MP_CROUCHWALK] = {"walk", "walk"},
        [ACT_MP_RUN] = {"run", "run"},
        [ACT_LAND] = {ACT_RESET, ACT_RESET},
        attack = "attack"
    },
    glide = ACT_IDLE,
}