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

    // Stop in front of the player instead of running into them.
    // Run sprite visual half-width ~25px + player 32px mask half-width:
    // 60px center-to-center keeps the bodies apart while the sword masks
    // (56px reach) still connect.
    var _attack_range = 60;
    var _dx = target_player.x - x;
    if (abs(_dx) <= _attack_range) {
        hspd = 0;
    } else {
        hspd = sign(_dx) * min(abs(_dx) - _attack_range, run_spd);
    }

    if (_dist <= _attack_range && attack_cooldown <= 0) {
        hspd = 0;
        state = enemy_states.attack;
        image_index = 0;
        legs_image_index = 0;
    }
}