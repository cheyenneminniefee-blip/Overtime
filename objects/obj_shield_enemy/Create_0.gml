event_inherited();

// --- Type Tuning ---
walk_spd = 1.0;
sight_range = 250;

// --- State Sprite Sets ---
spr_idle      = spr_shield_enemy_idle;      spr_idle_nm  = spr_shield_enemy_idle_nm;
spr_walk      = spr_shield_enemy_walk;      spr_walk_nm  = spr_shield_enemy_walk_nm;
spr_attack    = spr_shield_enemy_attack;    spr_attack_nm = spr_shield_enemy_attack_nm;
// --- Shield Overrides ---
spr_stunned = spr_shield_enemy_stunned;   spr_stunned_nm = spr_shield_enemy_stunned_nm;
blocks_frontal = true;   // Frontal shield absorbs 100% of standard damage
poise_threshold = 5;     // Tanky: takes more punishment before staggering
poise_window = 120;

// --- State AI Handlers ---
scr_walk   = scr_shield_enemy_walk;
scr_attack = scr_shield_enemy_attack;