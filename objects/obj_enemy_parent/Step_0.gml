// --- SHARED ENEMY STEP ---

// Time Freeze gate (PRD 5.2, 11.2): frozen hostiles do nothing — no AI, no
// physics, no animation advance. The time-domain manager owns the state.
if (global.time_frozen) {
    image_speed = 0;
    exit;
}

// Delta-time scale (see scr_dt): 1.0 at the nominal 60 steps/s; > 1 when
// steps are dropped. Velocities, timers, and animation advance scale by it.
var _dt = scr_dt();

// Decrement action timers
if (attack_cooldown > 0)     attack_cooldown -= _dt;
if (stun_immunity_timer > 0) stun_immunity_timer -= _dt;   // NEW
if (damage_window_timer > 0) damage_window_timer -= _dt;   // NEW
if (flash_timer > 0)         flash_timer -= _dt;           // NEW

// AI Core State Decisions
var move = 0;
if (state == enemy_states.walk) {
    move = facing_dir;
} else if (state == enemy_states.run && instance_exists(target_player)) {
    move = sign(target_player.x - x);
}

image_speed = _dt;

// Attacking drops horizontal acceleration to 0
if (state == enemy_states.attack) {
    move = 0;
}

// --- This-Frame Movement ---
// The state scripts run AFTER this physics block, so any run-state stop/
// retreat math done in scr_*_run would be stomped by the assignment below
// on the next frame before it ever moved the enemy. It has to live here.
if (state == enemy_states.run && instance_exists(target_player) && stop_range > 0) {
    var _dx = target_player.x - x;
    var _adx = abs(_dx);
    if (_adx < stop_range) {
        // Inside the player's body zone — back straight out to the stop line.
        // (-facing_dir covers the perfectly-stacked case where sign() is 0.)
        move = (_dx != 0) ? -sign(_dx) : -facing_dir;
        hspd = move * run_spd;
    } else {
        // Approach the stop line: full speed when far, exactly the remaining
        // overshoot when close — never crosses into the body zone.
        hspd = sign(_dx) * min(_adx - stop_range, run_spd);
    }
} else {
    hspd = move * ((state == enemy_states.run) ? run_spd : walk_spd);
}
vspd = vspd + grv * _dt;

var grounded = place_meeting(x, y + 1, obj_solid);

// Horizontal Collision System (per-frame displacement scales with delta time)
var _dx = hspd * _dt;
if (_dx != 0) {
    if (place_meeting(x + _dx, y, obj_solid)) {
        while (!place_meeting(x + sign(_dx), y, obj_solid)) {
            x += sign(_dx);
        }
        hspd = 0;
    }
    x += _dx;
}

// Vertical Collision System
var _dy = vspd * _dt;
if (_dy != 0) {
    if (place_meeting(x, y + _dy, obj_solid)) {
        while (!place_meeting(x, y + sign(_dy), obj_solid)) {
            y += sign(_dy);
        }
        vspd = 0;
    }
    y += _dy;
}

// --- Airborne And Landing State Tracker ---
if (!grounded) {
    was_airborne = true;
} else if (was_airborne) {
    draw_xscale = 1.4;
    draw_yscale = 0.6;
    was_airborne = false;
}

// Direction And Scale Normalization
if (hspd != 0) {
    facing_dir = sign(hspd);
}
draw_xscale = scr_dt_lerp(draw_xscale, 1, 0.1);
draw_yscale = scr_dt_lerp(draw_yscale, 1, 0.1);

// Manually animate the legs frame counter
legs_image_index += (legs_image_speed * sprite_get_speed(legs_sprite_index) / game_get_speed(gamespeed_fps)) * _dt;
legs_image_index = legs_image_index % sprite_get_number(legs_sprite_index);

// --- Apply The Sprite Set For The Current State ---
switch (state) {
    case enemy_states.idle:
        sprite_index      = spr_idle;
        normal_map        = spr_idle_nm;
        legs_sprite_index = spr_enemy_legs_idle;
        leg_normal_map    = spr_enemy_legs_idle_nm;
        legs_image_speed  = 1;
        image_index       = legs_image_index;
        break;

    case enemy_states.walk:
        sprite_index      = spr_walk;
        normal_map        = spr_walk_nm;
        legs_sprite_index = spr_enemy_legs_walk;
        leg_normal_map    = spr_enemy_legs_walk_nm;
        legs_image_speed  = 1;
        image_index       = legs_image_index;
        break;

    case enemy_states.run:
        // Parked at the body-stop line (within projectile reach of the
        // player but not approaching): idle pose instead of running in place.
        if (stop_range > 0 && instance_exists(target_player) && abs(target_player.x - x) <= stop_range + 2) {
            sprite_index      = spr_idle;
            normal_map        = spr_idle_nm;
            legs_sprite_index = spr_enemy_legs_idle;
            leg_normal_map    = spr_enemy_legs_idle_nm;
            legs_image_speed  = 1;
            image_index       = legs_image_index;
        } else {
            sprite_index      = spr_run;
            normal_map        = spr_run_nm;
            legs_sprite_index = spr_enemy_legs_run;
            leg_normal_map    = spr_enemy_legs_run_nm;
            legs_image_speed  = 1;
            image_index       = legs_image_index;
        }
        break;

    case enemy_states.attack:
        sprite_index      = spr_attack;
        normal_map        = spr_attack_nm;
        leg_normal_map    = -1;
        legs_image_speed  = 0;
        break;

    case enemy_states.stunned:   // NEW — full-body pose, legs hidden
        sprite_index      = spr_stunned;
        normal_map        = spr_stunned_nm;
        leg_normal_map    = -1;
        legs_image_speed  = 0;
        break;
}

// --- SAFETY NET (NEW) ---
// If a state change ever skips an attack script's cleanup (parry-stun,
// damage interrupts), make sure no hitbox is left floating in the room.
if (state != enemy_states.attack && attack_hitbox != noone && instance_exists(attack_hitbox)) {
    instance_destroy(attack_hitbox);
    attack_hitbox = noone;
}

// --- State Function Execution Selector ---
switch (state) {
    case enemy_states.idle:    if (scr_idle != noone)   scr_idle();   break;
    case enemy_states.walk:    if (scr_walk != noone)   scr_walk();   break;
    case enemy_states.run:     if (scr_run != noone)    scr_run();    break;
    case enemy_states.attack:  if (scr_attack != noone) scr_attack(); break;
    case enemy_states.stunned: scr_enemy_stunned();                   break;  // NEW
}