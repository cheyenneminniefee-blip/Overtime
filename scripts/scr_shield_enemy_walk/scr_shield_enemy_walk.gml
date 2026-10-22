// --- SHIELD WALK STATE ---
function scr_shield_enemy_walk() {
    if (scr_enemy_check_for_player()) {
        var _dist = point_distance(x, y, obj_player.x, obj_player.y);
        var _dir = sign(obj_player.x - x);

        facing_dir = _dir != 0 ? _dir : facing_dir;

        if (_dist <= 40 && attack_cooldown <= 0) {
            hspd = 0;
            state = enemy_states.attack;
            image_index = 0;
            return;
        }
    }

    var check_side = (facing_dir == 1) ? bbox_right + 1 : bbox_left - 1;
    var floor_ahead = position_meeting(check_side, bbox_bottom + 4, obj_solid);
    if (position_meeting(check_side, y, obj_solid) || !floor_ahead) {
        hspd = 0;
        state = enemy_states.idle;
        idle_timer = idle_duration;
    }
}