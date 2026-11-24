/// scr_enemy_stunned — shared stunned state loop
function scr_enemy_stunned() {
    // NOTE: do NOT zero hspd here — this script runs after physics, and the
    // parent movement block owns stunned horizontal motion (it decays any
    // knockback, e.g. the mace wave's shove, into a slow grounded slide;
    // scr_enemy_stun zeroes hspd at stun entry, so shoveless stuns hold).

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