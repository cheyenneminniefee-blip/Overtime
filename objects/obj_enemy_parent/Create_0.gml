/// obj_enemy_parent — shared base for all standard enemies
// The enum below is GLOBAL in GML. Declare it ONLY here — delete the
// per-enemy enum declarations from all child objects.
enum enemy_states {
    idle,
    walk,
    run,
    attack,
    stunned          // NEW
}

// --- Character Physics Variables ---
hspd = 0;
vspd = 0;
grv = 0.35;
walk_spd = 1.5;
run_spd = 3.5;                 // Only the melee enemy ever enters run

// --- Combat And State Variables ---
hp = 10;
idle_timer = 0;
idle_duration = 120;
attack_cooldown = 0;

state = enemy_states.walk;
facing_dir = 1;

// --- Vision Mechanics ---
sight_range = 450;
target_player = noone;
alerted = false;              // NEW — has this enemy EVER registered the player?

// --- Stun / Poise System (NEW) ---
stun_timer = 0;               // Frames of stun remaining
stun_immunity_timer = 0;      // Post-stun immunity (anti chain-lock)
stun_duration = 75;          // 2.5 seconds at 60fps
poise_threshold = 3;          // Damage absorbed inside the window before staggering
poise_window = 120;            // How long the damage "memory" lasts (frames)
damage_window_timer = 0;
damage_taken_window = 0;
blocks_frontal = false;       // Only the shield enemy overrides this


// --- Squash And Stretch Variables ---
draw_xscale = 1;
draw_yscale = 1;
was_airborne = false;

// --- Hitbox Instance Variables ---
attack_hitbox = noone;

// --- Legs Animation Controllers ---
legs_sprite_index = spr_enemy_legs_walk;
legs_image_index = 0;
legs_image_speed = 1;

flash_duration = 4;
flash_timer = 0;

normal_map = -1;
leg_normal_map = -1;

// --- State Sprite Sets ---
spr_idle       = -1;  spr_idle_nm       = -1;
spr_walk       = -1;  spr_walk_nm       = -1;
spr_run        = -1;  spr_run_nm        = -1;
spr_attack     = -1;  spr_attack_nm     = -1;
spr_stunned    = -1;  spr_stunned_nm    = -1;   // NEW

// --- State AI Handlers (children assign their own; idle is shared) ---
scr_idle   = scr_enemy_idle;
scr_walk   = noone;
scr_run    = noone;
scr_attack = noone;

// --- PURE SHADOW UNIFORMS ---
u_light_pos        = shader_get_uniform(shd_normal_map, "u_LightPos");
u_facing_dir       = shader_get_uniform(shd_normal_map, "u_FacingDir");
u_shadow_intensity = shader_get_uniform(shd_normal_map, "u_ShadowIntensity");
u_normal_map       = shader_get_sampler_index(shd_normal_map, "u_NormalMap");
u_light_radius     = shader_get_uniform(shd_normal_map, "u_LightRadius");
u_flash            = shader_get_uniform(shd_flash, "u_flash");   // NEW

shadow_level = 0.4;
gpu_set_texfilter(false);