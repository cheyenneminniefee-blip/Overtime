/// scr_enemy_stun(_duration)
// Knocks this enemy into the stunned state. Safe to call any time —
// already-stunned or stun-immune enemies ignore it (prevents chain-locks).
function scr_enemy_stun(_duration) {
    if (state == enemy_states.stunned || stun_immunity_timer > 0) {
        return;
    }

    stun_timer = _duration;

    // Cancel whatever they were doing (a parry interrupts mid-swing here)
    if (attack_hitbox != noone && instance_exists(attack_hitbox)) {
        instance_destroy(attack_hitbox);
        attack_hitbox = noone;
    }
    attack_cooldown = max(attack_cooldown, 30); // brief wind-up before retaliating
    hspd = 0;

    // Reset poise tracking so the stun isn't instantly re-earned
    damage_window_timer = 0;
    damage_taken_window = 0;

    // Dazed squash pop
    draw_xscale = 1.3;
    draw_yscale = 0.7;

    state = enemy_states.stunned;
}