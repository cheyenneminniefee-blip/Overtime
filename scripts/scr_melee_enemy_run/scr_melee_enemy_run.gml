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
    var _adx = abs(_dx);
    if (_adx < _attack_range) {
        // Already inside the player's body zone — step back out to the
        // stop line instead of standing overlapped.
        var _dir = _dx != 0 ? sign(_dx) : -facing_dir;
        hspd = -_dir * run_spd;
    } else {
        hspd = sign(_dx) * min(_adx - _attack_range, run_spd);
    }

    if (_dist <= _attack_range && attack_cooldown <= 0) {
        hspd = 0;
        state = enemy_states.attack;
        image_index = 0;
        legs_image_index = 0;
    }
}