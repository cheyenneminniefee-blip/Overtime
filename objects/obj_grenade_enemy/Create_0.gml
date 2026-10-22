event_inherited();

// --- Type Tuning ---
walk_spd = 1.25;
sight_range = 350;

// Grenadier-specific range bands
attack_range = 280;
flee_range = 120;

// --- State Sprite Sets ---
spr_idle      = spr_grenade_enemy_idle;      spr_idle_nm  = spr_grenade_enemy_idle_nm;
spr_walk      = spr_grenade_enemy_walk;      spr_walk_nm  = spr_grenade_enemy_walk_nm;
spr_attack    = spr_grenade_enemy_attack;    spr_attack_nm = spr_grenade_enemy_attack_nm;
spr_stunned   = spr_grenade_enemy_stunned;   spr_stunned_nm = spr_grenade_enemy_stunned_nm;

// --- State AI Handlers ---
scr_walk   = scr_grenade_enemy_walk;
scr_attack = scr_grenade_enemy_attack;