function scr_enemy_check_for_player() {
    if (instance_exists(obj_player)) {
        var _dist = point_distance(x, y, obj_player.x, obj_player.y);
        if (_dist <= sight_range) {
            var _dir_to_player = sign(obj_player.x - x);
            if (_dir_to_player == facing_dir || _dir_to_player == 0) {
                if (!collision_line(x, y - 16, obj_player.x, obj_player.y - 16, obj_solid, false, true)) {
                    target_player = obj_player;
                    alerted = true;   // NEW — this enemy has now "noticed" the player
                    return true;
                }
            }
        }
    }
    return false;
}