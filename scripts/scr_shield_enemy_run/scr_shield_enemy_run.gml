// --- SHIELD RUN STATE (pursuit at walking pace) ---
// Parity with scr_melee_enemy_run — one difference: the pursuit speed is the
// shield's walk pace (run_spd = walk_spd in Create), it never sprints.
// Movement toward/away from the player (stop line + retreat) is handled by
// the parent Step via stop_range — hspd writes here are ignored, since the
// frame's velocity is already committed. This script only decides when to bash.
function scr_shield_enemy_run() {
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

    // Re-aim at the player each frame: the parent's direction normalization
    // flips facing_dir to match movement (and the stop-line retreat moves
    // AWAY from the player), and this runs after it. The bash is frontal,
    // so it can never fire aimed away from the target.
    var _ldx = target_player.x - x;
    if (_ldx != 0) facing_dir = sign(_ldx);

    if (_dist <= attack_range && attack_cooldown <= 0) {
        state = enemy_states.attack;
        image_index = 0;
        legs_image_index = 0;
    }
}
