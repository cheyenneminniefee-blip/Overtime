var _p = other;

// Time Freeze (PRD 5.2): frozen hostiles cannot hurt the player at all
if (global.time_frozen) exit;

// Mercy i-frames & active dodge frames: nothing happens at all
if (_p.invuln_timer > 0) exit;
if (_p.state == player_states.dodge && _p.dodge_timer > 0) exit;

// --- BLOCK & PARRY ---
// HEAVY-type attacks (PRD 6.2/7.2) skip this whole section: unblockable, full
// damage through guard, must be dodged — and a parry cannot touch an
// uninterruptible heavy attacker.
if (!unblockable && _p.state == player_states.block) {

    if (_p.parry_timer > 0) {
        // PERFECT PARRY — stun the attacker.
        // (scr_enemy_stun destroys this very hitbox, so exit right after.)
        if (owner != noone && instance_exists(owner)) {
            with (owner) {
                scr_enemy_stun(stun_duration);
                // Anti-turtle bookkeeping (PRD 7.2): a parry resets the
                // heavy trigger's aggression — it never feeds the counters.
                blocked_hit_count = 0;
                melee_range_timer = 0;
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

    // Anti-turtle bookkeeping (PRD 7.2): a plain block counts toward the
    // enemy's heavy trigger (blocked the last 2 attacks -> heavy). Only plain
    // blocks count — parries and clean hits never feed the streak — and only
    // ONCE per swing, not once per overlap step.
    if (owner != noone && instance_exists(owner) && !hit_counted) {
        owner.blocked_hit_count += 1;
        hit_counted = true;
    }
    exit;
}

// --- CLEAN HIT ---
var _dmg = damage;
var _src_x = x;
with (_p) {
    scr_player_take_damage(_dmg, _src_x);
}

// A clean hit breaks the block-streak the heavy trigger was counting on
if (owner != noone && instance_exists(owner)) {
    owner.blocked_hit_count = 0;
}