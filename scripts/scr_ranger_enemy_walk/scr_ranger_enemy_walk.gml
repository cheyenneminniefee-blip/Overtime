// --- RANGER WALK STATE ---
function scr_ranger_enemy_walk() {
    if (instance_exists(obj_player)) {
        var _dist = point_distance(x, y, obj_player.x, obj_player.y);
        var _dir_to_player = sign(obj_player.x - x);

        if (!collision_line(x, y - 16, obj_player.x, obj_player.y - 16, obj_solid, false, true)) {
    alerted = true;   // NEW — spotted the player; ambush stuns are off the table
    if (_dist <= attack_range && _dist > flee_range) {
                if (attack_cooldown <= 0) {
                    facing_dir = _dir_to_player != 0 ? _dir_to_player : facing_dir;
                    hspd = 0;
                    state = enemy_states.attack;
                    image_index = 0;
                    return;
                }
            } else if (_dist <= flee_range) {
                facing_dir = -_dir_to_player;
            } else if (_dist <= sight_range) {
                facing_dir = _dir_to_player;
            }
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