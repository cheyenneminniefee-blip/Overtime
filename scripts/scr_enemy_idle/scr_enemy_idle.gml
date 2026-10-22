// --- SHARED ENEMY IDLE STATE ---
function scr_enemy_idle() {
    // Player spotted — hand off to walk, which decides what to do about it
    if (scr_enemy_check_for_player()) {
        state = enemy_states.walk;
        return;
    }

    if (idle_timer > 0) {
        idle_timer -= 1;
    }

    if (idle_timer <= 0) {
        facing_dir = -facing_dir;
        state = enemy_states.walk;
    }
}