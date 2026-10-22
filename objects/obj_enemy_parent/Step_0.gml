// --- SHARED ENEMY STEP ---

// Decrement action timers
if (attack_cooldown > 0)     attack_cooldown -= 1;
if (stun_immunity_timer > 0) stun_immunity_timer -= 1;   // NEW
if (damage_window_timer > 0) damage_window_timer -= 1;   // NEW
if (flash_timer > 0)         flash_timer -= 1;           // NEW

// AI Core State Decisions
var move = 0;
if (state == enemy_states.walk) {
    move = facing_dir;
} else if (state == enemy_states.run && instance_exists(target_player)) {
    move = sign(target_player.x - x);
}

image_speed = 1;

// Attacking drops horizontal acceleration to 0
if (state == enemy_states.attack) {
    move = 0;
}

hspd = move * ((state == enemy_states.run) ? run_spd : walk_spd);
vspd = vspd + grv;

var grounded = place_meeting(x, y + 1, obj_solid);

// Horizontal Collision System
if (place_meeting(x + hspd, y, obj_solid)) {
    while (!place_meeting(x + sign(hspd), y, obj_solid)) {
        x += sign(hspd);
    }
    hspd = 0;
}
x += hspd;

// Vertical Collision System
if (place_meeting(x, y + vspd, obj_solid)) {
    while (!place_meeting(x, y + sign(vspd), obj_solid)) {
        y += sign(vspd);
    }
    vspd = 0;
}
y += vspd;

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
draw_xscale = lerp(draw_xscale, 1, 0.1);
draw_yscale = lerp(draw_yscale, 1, 0.1);

// Manually animate the legs frame counter
legs_image_index += (legs_image_speed * sprite_get_speed(legs_sprite_index) / game_get_speed(gamespeed_fps));
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
        sprite_index      = spr_run;
        normal_map        = spr_run_nm;
        legs_sprite_index = spr_enemy_legs_run;
        leg_normal_map    = spr_enemy_legs_run_nm;
        legs_image_speed  = 1;
        image_index       = legs_image_index;
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