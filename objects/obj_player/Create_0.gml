// --- Resources: Stamina & Energy (PRD 5.6) ---
stamina = 100;
stamina_max = 100;
stamina_regen_delay = 0;         // 0.5 s (30 f) after the last sprint / dodge / block
stamina_regen_delay_max = 30;
sprint_needs_reengage = false;   // anti-flutter: after emptying, sprint needs 30 to re-engage
energy = 100;
energy_max = 100;

// --- Photon Grenades (PRD 5.7) ---
grenades = 3;
grenades_max = 3;
has_grenades = true;   // Debug-on: the PRD unlock lands at the L2 exit (M1c)
has_phase_slash = true;   // Debug-on: PRD unlock is the L6 Phase Slash pickup (M1c/M2) — gates the energy HUD (12.1)
has_freeze = true;        // Debug-on: the energy bar appears when either ability is unlocked (PRD 12.1)

// Character Physics Variables
hspd = 0;
vspd = 0;
grv = 0.35;
walk_spd = 4;
sprint_spd=7;
sprint_buffer=0;
jump_spd = -7;

// Combat And Ability Variables
hp = HP_MAX;             // PRD 4.2: max HP 100
hp_max = HP_MAX;
is_overtime = false;
overtime_timer = 0;
phase_slash_cooldown = 0;      // 2.0 s between Phase Slashes, charged only on a real teleport (PRD 5.3)
phase_slash_cd_max = 120;
phase_slash_cost = 40;         // 40 energy per real teleport (PRD 5.3, 5.6)
phase_slash_range = 160;       // 5 tiles (PRD 5.3)
phase_teleported = false;

// --- Heavy weapon slot (PRD 5.8) ---
// Selected at the post-Traefin L6 armory pedestals (or any checkpoint's swap
// menu). Debug-on so the greatsword is testable now; set to WEAPON.NONE to
// restore the pre-armory behavior where holding the attack button does
// nothing beyond the normal sword swing.
heavy_weapon = WEAPON.GREATSWORD;
heavy_hold_timer = -1;   // frames the attack button has been held; -1 = not held / committed

// State Machine Initialization
enum player_states {
    idle,
    walk,
    jump,
	sprint,
	phase_slash,
    idle_attack_1,
	idle_attack_2,
	idle_attack_3,
	walk_attack_1,
	walk_attack_2,
	up_attack,
	down_attack,
	air_attack,
	dodge,
	wall_hang,
	block,
	heavy_attack,
}
state = player_states.idle;
facing_dir = 1;

// Squash And Stretch Variables
draw_xscale = 1;
draw_yscale = 1;
was_airborne = false;

// Hitbox Instance Variables
attack_hitbox = noone;
attack_cooldown=0;
combo_timer=0;
buffer_lockout_timer = 0;

combo_step = 0;
walk_combo_step = 0;

// Legs Animation Controllers
legs_sprite_index = spr_player_legs_idle; 
legs_image_index = 0;
legs_image_speed = 1;

dodge_spd = 8;           // 480 px/s burst — 2x walk, faster than sprint (PRD 5.5)
dodge_duration = 12;     // 0.2 s burst at 60 fps
dodge_timer = 0;         // Track remaining active dodge frames
dodge_cooldown = 0;      // 0.5 s between dodges, anchored to dodge end (PRD 5.5)
dodge_cooldown_max = 30;
dodge_was_air = false;   // This dodge started airborne — gravity suspended for the whole burst
dodge_air_used = false;  // One air dodge per airborne period, refreshed on landing
dodge_ghosts = [];       // After-image ghosts (draw-only): {spr, ind, x, y, xs, ys, t}
dodge_ghost_tick = 0;    // Ghost spawn accumulator: one ghost per 4 nominal frames (dt-scaled)
ghost_life = 12;         // 6 PRD frames at 60 fps

flash_duration = 4;      // How many frames at the start of the dash the player stays white
flash_timer = 0;         // Track remaining active shader frames

wall_jump_timer = 0;

normal_map = spr_player_idle_nm;
leg_normal_map = spr_player_legs_idle_nm;

// --- Damage & Parry Variables ---
invuln_timer = 0;      // Mercy invulnerability frames after taking a hit
hurt_timer = 0;        // Input lockout while hit knockback plays
parry_window = 8;      // Frames after raising the block that count as a perfect parry
parry_timer = 0;       // Counts down from parry_window once block starts
freeze_fizzle_timer = 0;  // Pulses the energy border when a Freeze request is rejected (PRD 5.2)
u_flash = shader_get_uniform(shd_flash, "u_flash");

// --- PURE SHADOW UNIFORMS ---
u_light_pos        = shader_get_uniform(shd_normal_map, "u_LightPos");
u_facing_dir       = shader_get_uniform(shd_normal_map, "u_FacingDir");
u_shadow_intensity = shader_get_uniform(shd_normal_map, "u_ShadowIntensity");
u_normal_map       = shader_get_sampler_index(shd_normal_map, "u_NormalMap");
u_light_radius	   = shader_get_uniform(shd_normal_map, "u_LightRadius");

// --- TUNING ---
// 0.0 = no shadow at all. 1.0 = pitch black shadow.
// 0.4 gives a gorgeous, clean 40% darkening effect perfect for pixel art.
shadow_level = 0.4;

gpu_set_texfilter(false);