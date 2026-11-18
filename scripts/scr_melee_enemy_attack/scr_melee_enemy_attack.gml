// --- MELEE ATTACK STATE ---
function scr_melee_enemy_attack() {
    var _frame = floor(image_index);

    // Strike lands on frames 5-6 of the swing; the hb sprite is this same
    // timeline resampled to 9 frames, so its masks sit one frame ahead
    // (hb 6-7 = enemy 5-6).
    if (_frame >= 5 && _frame <= 6) {
        if (!instance_exists(attack_hitbox)) {
            attack_hitbox = instance_create_layer(x, y, layer, obj_enemy_melee_hitbox);
        }
        attack_hitbox.x = x;
        attack_hitbox.y = y;
        attack_hitbox.sprite_index = spr_melee_enemy_attack_hb;
        attack_hitbox.image_index = image_index + 1;
        attack_hitbox.image_xscale = facing_dir;
        attack_hitbox.owner = id;
        attack_hitbox.damage = 15;   // Standard Cyborg slash (PRD 7.2)
    } else if (instance_exists(attack_hitbox)) {
        instance_destroy(attack_hitbox);
        attack_hitbox = noone;
    }

    if (image_index >= image_number - 1) {
        attack_cooldown = 45;

        if (instance_exists(attack_hitbox)) {
            instance_destroy(attack_hitbox);
            attack_hitbox = noone;
        }

        if (instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) <= sight_range) {
            state = enemy_states.run;
        } else {
            state = enemy_states.walk;
        }
    }
}