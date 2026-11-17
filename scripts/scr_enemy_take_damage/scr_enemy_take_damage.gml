/// scr_enemy_take_damage(_amount, _from_x, _bypass_shield)
// _amount        — HP to remove
// _from_x        — x coordinate the hit came from (shield facing check)
// _bypass_shield — true for Phase Slash / grenades (PRD: both ignore the shield)
function scr_enemy_take_damage(_amount, _from_x, _bypass_shield) {

    // --- 0. TIME FREEZE (PRD 5.2) ---
    // Frozen enemies take half damage from every source (fractions kept) and
    // do not flinch: no flash, no squash, no poise damage, no stun. They still
    // die — the death block below resolves fully while frozen (kill credit,
    // +5 s Overtime, +15 energy, destroy).
    var _frozen = global.time_frozen;
    if (_frozen) {
        _amount *= FROZEN_DAMAGE_MULT;
        _bypass_shield = true;   // a frozen enemy cannot hold its shield up
    }

    // --- 1. SHIELD CHECK (shield enemy only) ---
    // The shield absorbs 100% of frontal damage while raised.
    // It's raised whenever the enemy isn't attacking and isn't stunned.
    if (blocks_frontal && !_bypass_shield
    && state != enemy_states.attack && state != enemy_states.stunned) {
        var _hit_from_front = (sign(_from_x - x) == facing_dir);
        if (_hit_from_front) {
            // Fully blocked — no damage, no poise, no stun
            flash_timer = 2; // tiny flash tick so it FEELS like it connected
            exit;
        }
    }

    // --- 2. APPLY DAMAGE ---
    hp -= _amount;
    if (!_frozen) {
        flash_timer = flash_duration;
        draw_xscale = 1.25;   // quick hurt squash (existing lerp normalizes it)
        draw_yscale = 0.8;
    }

    // --- 3. DEATH ---
    if (hp <= 0) {
        if (instance_exists(obj_player)) {
            // PRD: Overtime — each enemy kill buys +5 seconds
            if (obj_player.is_overtime) {
                obj_player.overtime_timer += 300;
            }
            // PRD 5.6: kills bank +15 energy (also during Overtime)
            obj_player.energy = min(obj_player.energy_max, obj_player.energy + 15);
        }

        // Corpse: plays the death animation once, then holds its last frame
        // (death FX resolve immediately, even while frozen — PRD 5.2)
        var _corpse = instance_create_layer(x, y, layer, obj_enemy_death);
        _corpse.facing_dir = facing_dir;
        _corpse.draw_xscale = draw_xscale;
        _corpse.draw_yscale = draw_yscale;
        _corpse.overlay_sprite = death_overlay;

        instance_destroy();
        exit;
    }

    // A frozen enemy does not change state: no ambush or poise stun (PRD 5.2)
    if (_frozen) exit;

    // --- 4. AMBUSH STUN ---
    // Damaged before they ever noticed the player = instant stun
    if (!alerted) {
        alerted = true;
        scr_enemy_stun(stun_duration);
        exit;
    }

    alerted = true;

    // --- 5. POISE STUN ---
    // Too much damage inside the poise window = stagger
    if (damage_window_timer <= 0) {
        damage_window_timer = poise_window;
        damage_taken_window = 0;
    }
    damage_taken_window += _amount;

    if (damage_taken_window >= poise_threshold) {
        damage_window_timer = 0;
        damage_taken_window = 0;
        scr_enemy_stun(stun_duration);
    }
}