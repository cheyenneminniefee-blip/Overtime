/// obj_player_hitbox — player melee damage dealer
damage = SWORD_DAMAGE;      // Hard Light Sword baseline, 18 (PRD 5.8); the heavy script overrides
poise_mult = 1.0;           // Poise damage multiplier (PRD 5.8: heavy 2x/1.5x/3x; sword 1x)
hit_list = [];   // Enemies already struck during THIS swing (prevents multi-hits)