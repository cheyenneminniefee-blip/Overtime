var _p = other;

// A parried bolt is player-owned and can no longer hit the player (PRD 6.3)
if (reflected) exit;

// Time Freeze (PRD 5.2): frozen hostiles cannot hurt the player at all
if (global.time_frozen) exit;

// Mercy i-frames & active dodge frames: the bolt passes through untouched
if (_p.invuln_timer > 0) exit;
if (_p.state == player_states.dodge && _p.dodge_timer > 0) exit;

// --- BLOCK & PARRY (PRD 5.4 — ION is parryable) ---
if (_p.state == player_states.block) {

    if (_p.parry_timer > 0) {
        // PERFECT PARRY — stun the shooter and reflect the bolt at 1.5x speed
        if (owner != noone && instance_exists(owner)) {
            with (owner) {
                scr_enemy_stun(stun_duration);
            }
        }

        // Reflect straight back along the incoming path at 1.5x speed (PRD 5.4)
        hspd = -hspd * 1.5;
        vspd = -vspd * 1.5;
        reflected = true;
        owner = noone;
        lifetime = max(lifetime, 90);
        _p.flash_timer = _p.flash_duration;
        _p.draw_xscale = 1.25;
        _p.draw_yscale = 0.8;
        exit;
    }

    // Regular block: bolt negated; blocking a hit drains 10 stamina (PRD 5.6)
    _p.stamina = max(0, _p.stamina - 10);
    _p.stamina_regen_delay = _p.stamina_regen_delay_max;
    instance_destroy();
    exit;
}

// --- CLEAN HIT ---
var _dmg = damage;
var _src_x = x;
instance_destroy();
with (_p) {
    scr_player_take_damage(_dmg, _src_x);
}
