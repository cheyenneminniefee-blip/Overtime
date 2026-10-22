// --- MELEE WALK STATE ---
function scr_melee_enemy_walk() {
    // Player spotted mid-patrol — give chase.
    // FIX: the old code cached the target but never changed state, which made
    // the run state unreachable. See notes below if the old behavior was intended.
    if (scr_enemy_check_for_player()) {
        state = enemy_states.run;
        return;
    }

    var check_side = (facing_dir == 1) ? bbox_right + 1 : bbox_left - 1;
    var floor_ahead = position_meeting(check_side, bbox_bottom + 4, obj_solid);
    if (position_meeting(check_side, y, obj_solid) || !floor_ahead) {
        hspd = 0;
        state = enemy_states.idle;
        idle_timer = idle_duration;
    }
}