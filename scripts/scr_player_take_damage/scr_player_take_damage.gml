/// scr_player_take_damage(_amount, _from_x)
function scr_player_take_damage(_amount, _from_x) {

    // --- INVULNERABILITY GATES ---
    if (invuln_timer > 0) return;                            // mercy i-frames
    if (state == player_states.dodge && dodge_timer > 0) return; // dodge i-frames

    // --- OVERTIME: any damage is instant true death (PRD) ---
    if (is_overtime) {
        // TODO: route into the Afterlife system when you build it
        game_restart();
        return;
    }

    // --- APPLY DAMAGE ---
    hp -= _amount;
    invuln_timer = 60;   // 1 second of mercy invulnerability
    hurt_timer = 12;     // input lockout so the knockback actually plays
    wall_jump_timer = max(wall_jump_timer, 10); // don't insta-latch to a wall mid-hit

    // Cancel any active attack and clean up its hitbox
    if (attack_hitbox != noone && instance_exists(attack_hitbox)) {
        instance_destroy(attack_hitbox);
        attack_hitbox = noone;
    }
    attack_buffered = false;

    // --- KNOCKBACK ---
    var _dir = sign(x - _from_x);
    if (_dir == 0) _dir = -facing_dir;
    hspd = _dir * 4;
    vspd = -3;

    // --- JUICE ---
    flash_timer = flash_duration;
    draw_xscale = 1.3;
    draw_yscale = 0.7;

    // Interrupt into a knocked-airborne state; your existing step-event
    // Overtime machine catches hp <= 0 on the next frame
    state = player_states.jump;
}