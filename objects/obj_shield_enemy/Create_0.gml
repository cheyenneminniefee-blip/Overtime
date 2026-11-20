event_inherited();

// --- Type Tuning ---
walk_spd = 1.0;
sight_range = 250;

// --- Aggression (same pipeline as the melee enemy, walking pace) ---
// The shield never sprints: its "run" state is a pursuit at walking speed,
// drawn with its walk sprite set. The parent Step's stop_range block owns
// approach/retreat once in pursuit.
run_spd = walk_spd;                            // pursue at walking pace (PRD 7.2)
spr_run      = spr_shield_enemy_walk;      spr_run_nm  = spr_shield_enemy_walk_nm;
stop_range = 74;       // walk sprite half-width 39 + player 32 mask half + 3 gap: retreat/idle-pose line
attack_range = 80;     // swing trigger (bash mask reaches 56; at 80 the player edge is 48 away)

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
scr_run    = scr_shield_enemy_run;
scr_attack = scr_shield_enemy_attack;

// --- Death Prop ---
death_overlay = spr_enemy_shield_death;