// --- MELEE RUN STATE ---
// Movement toward/away from the player (stop line + retreat) is handled by
// the parent Step via stop_range — by the time this script runs, this
// frame's velocity is already committed, so hspd writes here are ignored.
// This script only decides when to swing.
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

    // The parent's direction normalization flips facing_dir to match
    // movement — and retreat moves AWAY from the player — so re-aim at the
    // player here (this runs after that normalization). Keeps the enemy
    // facing the target while backing off, and the swing fires the right way.
    var _ldx = target_player.x - x;
    if (_ldx != 0) facing_dir = sign(_ldx);

    if (_dist <= stop_range && attack_cooldown <= 0) {
        state = enemy_states.attack;
        image_index = 0;
        legs_image_index = 0;
    }
}
