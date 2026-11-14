var _p = other;

// Mercy i-frames & active dodge frames: nothing happens at all
if (_p.invuln_timer > 0) exit;
if (_p.state == player_states.dodge && _p.dodge_timer > 0) exit;

// --- BLOCK & PARRY ---
if (_p.state == player_states.block) {

    if (_p.parry_timer > 0) {
        // PERFECT PARRY — stun the attacker.
        // (scr_enemy_stun destroys this very hitbox, so exit right after.)
        if (owner != noone && instance_exists(owner)) {
            with (owner) {
                scr_enemy_stun(stun_duration);
            }
        }

        // Reward juice on the player
        _p.flash_timer = _p.flash_duration;
        _p.draw_xscale = 1.25;
        _p.draw_yscale = 0.8;
        exit;
    }

    // Regular block: hit fully negated; blocking a hit drains 10 stamina (PRD 5.6)
    _p.stamina = max(0, _p.stamina - 10);
    _p.stamina_regen_delay = _p.stamina_regen_delay_max;
    exit;
}

// --- CLEAN HIT ---
var _dmg = damage;
var _src_x = x;
with (_p) {
    scr_player_take_damage(_dmg, _src_x);
}