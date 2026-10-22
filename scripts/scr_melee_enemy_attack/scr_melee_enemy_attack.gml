// --- MELEE ATTACK STATE ---
function scr_melee_enemy_attack() {
    var _frame = floor(image_index);

    // Hitbox lives for frames 0–4 of the swing
    if (_frame <= 4) {
        if (!instance_exists(attack_hitbox)) {
            attack_hitbox = instance_create_layer(x, y, layer, obj_enemy_melee_hitbox);
        }
        attack_hitbox.x = x;
        attack_hitbox.y = y;
        attack_hitbox.sprite_index = spr_melee_enemy_attack_hb;
        attack_hitbox.image_index = image_index;
        attack_hitbox.image_xscale = facing_dir;
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