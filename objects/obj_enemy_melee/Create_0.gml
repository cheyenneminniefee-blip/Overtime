event_inherited();

// --- Type Tuning ---
walk_spd = 1.5;
run_spd = 3.5;
sight_range = 450;

// --- State Sprite Sets ---
spr_idle      = spr_melee_enemy_idle;      spr_idle_nm  = spr_melee_enemy_idle_nm;
spr_walk      = spr_melee_enemy_walk;      spr_walk_nm  = spr_melee_enemy_walk_nm;
spr_run       = spr_melee_enemy_run;       spr_run_nm   = spr_melee_enemy_run_nm;
spr_attack    = spr_melee_enemy_attack;    spr_attack_nm = spr_melee_enemy_attack_nm;
spr_stunned	  = spr_melee_enemy_stunned;   spr_stunned_nm = spr_melee_enemy_stunned_nm;

// --- State AI Handlers ---
scr_walk   = scr_melee_enemy_walk;
scr_run    = scr_melee_enemy_run;
scr_attack = scr_melee_enemy_attack;