/// scr_enemy_stunned — shared stunned state loop
function scr_enemy_stunned() {
    hspd = 0; // fully locked; gravity still applies from the parent physics

    if (stun_timer > 0) {
        stun_timer -= 1;
        if (stun_timer <= 0) {
            // Wake up: short immunity + a beat of re-orientation
            stun_immunity_timer = 90;
            idle_timer = 30;
            alerted = true;
            state = enemy_states.idle;
        }
    }
}