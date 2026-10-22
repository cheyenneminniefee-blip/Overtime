// --- MELEE RUN STATE ---
function scr_melee_enemy_run() {
    if (!instance_exists(target_player)) {
        state = enemy_states.walk;
        return;
    }

    var _dist = point_distance(x, y, target_player.x, target_player.y);

    if (_dist > sight_range || collision_line(x, y - 16, target_player.x, target_player.y - 16, obj_solid, false, true)) {
        target_player = noone;
        state = enemy_states.walk;
        return;
    }

    var attack_range = 35;
    if (_dist <= attack_range && attack_cooldown <= 0) {
        hspd = 0;
        state = enemy_states.attack;
        image_index = 0;
        legs_image_index = 0;
    }
}