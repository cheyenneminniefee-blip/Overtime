// Character Physics Variables
hspd = 0;
vspd = 0;
grv = 0.35;
walk_spd = 4;
sprint_spd=7;
sprint_buffer=0;
jump_spd = -7;

// Combat And Ability Variables
hp = 3;
is_overtime = false;
overtime_timer = 0;
phase_slash_cooldown = 0;
time_freeze_timer = 0;
time_freeze_cd_timer = 0;
global.time_frozen = false;

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

dodge_spd = 7;          // Horizontal velocity multiplier during the dash
dodge_duration = 20;     // Total duration of the dodge in frames
dodge_timer = 0;         // Track remaining active dodge frames
dodge_cooldown = 0;      // Anti-spam cooldown timer

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