/// scr_enemy_stunned — shared stunned state loop
function scr_enemy_stunned() {
    hspd = 0; // fully locked; gravity still applies from the parent physics

    if (stun_timer > 0) {
        stun_timer -= 1;
        if (stun_timer <= 0) {
            // Wake up: short immunity + a beat of re-orientation. The mace's
            // ground wave extends the immunity to 3 s (PRD 5.8) so a full
            // mace cycle can never stun-lock.
            stun_immunity_timer = max(90, wave_stun_immunity);
            wave_stun_immunity = 0;
            idle_timer = 30;
            alerted = true;
            state = enemy_states.idle;
        }
    }
}