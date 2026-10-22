event_inherited();

// --- Type Tuning ---
walk_spd = 1.5;
sight_range = 300;

// Ranger-specific range bands
attack_range = 200;
flee_range = 100;

// --- State Sprite Sets ---
spr_idle      = spr_ranger_enemy_idle;      spr_idle_nm  = spr_ranger_enemy_idle_nm;
spr_walk      = spr_ranger_enemy_walk;      spr_walk_nm  = spr_ranger_enemy_walk_nm;
spr_attack    = spr_ranger_enemy_attack;    spr_attack_nm = spr_ranger_enemy_attack_nm;
spr_stunned   = spr_ranger_enemy_stunned;   spr_stunned_nm = spr_ranger_enemy_stunned_nm;

// --- State AI Handlers ---
scr_walk   = scr_ranger_enemy_walk;
scr_attack = scr_ranger_enemy_attack;