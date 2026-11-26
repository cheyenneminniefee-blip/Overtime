// --- MELEE RUN STATE ---
// Movement toward/away from the player (stop line + retreat) is handled by
// the parent Step via stop_range — by the time this script runs, this
// frame's velocity is already committed, so hspd writes here are ignored.
// This script only decides when to swing.
function scr_melee_enemy_run() {
    if (!instance_exists(target_player)) {
        state = enemy_states.walk;
        return;
    }

    var _dist = point_distance(x, y, target_player.x, target_player.y);

    if (_dist > sight_range || collision_line(x, y - 16, target_player.x, target_player.y - 16, obj_solid, false, true)) {
        target_player = noone;
        state = enemy_states.walk;
        return;
    }

    // The parent's direction normalization flips facing_dir to match
    // movement — and retreat moves AWAY from the player — so re-aim at the
    // player here (this runs after that normalization). Keeps the enemy
    // facing the target while backing off, and the swing fires the right way.
    var _ldx = target_player.x - x;
    if (_ldx != 0) facing_dir = sign(_ldx);

    // --- ANTI-TURTLE BOOKKEEPING (PRD 7.2) ---
    // Time spent in melee range feeds the heavy trigger; leaving the range
    // clears it. Blocked-hit counting lives in obj_enemy_melee_hitbox (the
    // player's block path), clean hits clear it (see that script).
    if (_dist <= attack_range) {
        melee_range_timer += 1;
    } else {
        melee_range_timer = 0;
    }

    if (_dist <= attack_range && attack_cooldown <= 0) {   // swings from 60; retreat/idle line is stop_range (55)
        // --- HEAVY TRIGGERS (PRD 7.2 anti-turtle + escalation pattern) ---
        // Any ONE of these causes the swing to escalate into the heavy:
        //   1. every MELEE_HEAVY_EVERY_Nth attack thrown is a guaranteed
        //      heavy, blocked or not (attack_count counts every attack we
        //      initiate, then the cycle restarts after each heavy)
        //   2. otherwise a random roll every attack
        //   3. the player plain-blocked the last 2 attacks (parries never
        //      count — a parry stuns + resets aggression instead)
        //   4. 3 s of standing inside melee range
        attack_count += 1;
        var _go_heavy = (attack_count >= MELEE_HEAVY_EVERY_N)
                     || (random(1) < MELEE_HEAVY_RANDOM_CHANCE)
                     || (blocked_hit_count >= MELEE_HEAVY_BLOCKS_TO_HEAVY)
                     || (melee_range_timer >= MELEE_HEAVY_RANGE_TIME);

        // Trigger bookkeeping restarts with whatever attack we pick
        blocked_hit_count = 0;
        melee_range_timer = 0;

        image_index = 0;
        legs_image_index = 0;
        if (_go_heavy) {
            attack_count = 0;                 // the guaranteed-Nth cycle restarts after every heavy
            state = enemy_states.heavy_attack;
            heavy_attack_locked = true;       // uninterruptible until recovery ends
            poise_break_deferred = false;
        } else {
            state = enemy_states.attack;
        }
    }
}
