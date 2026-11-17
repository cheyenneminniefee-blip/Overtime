/// scr_time_domain — the single time authority (PRD 11.2)
// Priority ascending: PAUSE > DIALOGUE > HITSTOP > FROZEN > RUN. Every
// subsystem queries scr_time_state(); ad-hoc pause flags are deprecated.
// Only RUN and FROZEN are reachable today — HITSTOP, DIALOGUE, and PAUSE
// arrive with their systems and slot into the ladder.

enum TIME {
    RUN,
    FROZEN,
    HITSTOP,
    DIALOGUE,
    PAUSE
}

// Top-level init: runs once at game start, before any room or instance Create
global.time_frozen = false;
global.time_state = TIME.RUN;

// Grenade chain caps (PRD 6.7)
global.detonations_frame = 0;
global.detonation_chain_count = 0;
global.last_detonate_us = 0;
global.detonation_chain_start_us = 0;

function scr_time_state() {
    return global.time_state;
}

function scr_freeze_set(_on) {
    if (!variable_global_exists("time_frozen")) global.time_frozen = false;
    if (_on == global.time_frozen) return;   // idempotent — no double-apply, no lost mem_*
    global.time_frozen = _on;
    global.time_state = _on ? TIME.FROZEN : TIME.RUN;
    with (obj_enemy_parent) {
        if (_on) {
            mem_image_speed = image_speed;
            image_speed = 0;
            image_blend = FREEZE_TINT;
        } else {
            image_speed = mem_image_speed;
            image_blend = c_white;
        }
    }
}

function scr_time_freeze_request() {
    // Bootstrap the authority so freeze works from any entry room
    if (!instance_exists(obj_time_domain)) {
        instance_create_layer(0, 0, layer, obj_time_domain);
    }
    if (global.time_state != TIME.RUN) return false;           // one charge, no stacking
    if (obj_time_domain.freeze_cd_timer > 0) {                 // 30 s cooldown (PRD 5.2)
        scr_freeze_fizzle();
        return false;
    }
    if (energy < energy_max) {                                 // full-meter gate (PRD 5.2)
        scr_freeze_fizzle();
        return false;
    }
    obj_time_domain.freeze_timer = FREEZE_DURATION;
    obj_time_domain.freeze_cd_timer = FREEZE_COOLDOWN;         // starts at activation
    energy = 0;                                                // drains the meter (PRD 5.6)
    scr_freeze_set(true);
    return true;
}

function scr_freeze_fizzle() {
    // Rejected activation: a fizzle — the energy meter border pulses icy blue
    // (PRD 5.2; the dedicated freeze icon arrives with the HUD icon pass)
    if (instance_exists(obj_player)) {
        obj_player.freeze_fizzle_timer = 12;
    }
}
