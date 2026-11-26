/// scr_melee_enemy_heavy_attack — Standard Cyborg heavy (PRD 6.4 / 7.2)
/// Type HEAVY: unblockable, full damage through guard, must be dodged (AC28).
/// Uninterruptible (heavy_attack_locked = true from entry to recovery end):
///   - scr_enemy_stun refuses mid-heavy (parry cannot touch it; the mace's
///     ground wave skips without starting the stun-immunity timer)
///   - poise damage still accrues but a poise break is DEFERRED (flagged in
///     scr_enemy_take_damage) and the stagger lands the moment recovery ends
///   - the attacker takes damage normally; Time Freeze suspends the attack
///     and resumes it (the parent's frozen gate pauses everything, and this
///     script's manual advance simply stops running)
/// Trigger (PRD 7.2 anti-turtle): the player plain-blocked the last 2 attacks
/// or 3 s in melee range — chosen in scr_melee_enemy_run.
///
/// Animation pacing: the authored 22-frame sprite runs via manual advance
/// (image_speed forced to 0 — the parent sets 1 every frame for native
/// advance). The wind-up (frames 0..13, mask onset at 14) is stretched to
/// MELEE_HEAVY_WINDUP (0.8 s @60fps) so the mandatory >=0.4 s telegraph
/// reads; body and _hb sprites are authored frame-aligned 1:1, so the
/// hitbox mirrors image_index directly (no resample offset like the slash).
function scr_melee_enemy_heavy_attack() {
    image_speed = 0;   // manual advance only (parent pre-sets 1 for the slash)
    image_index += MELEE_HEAVY_STRIKE_FRAME / MELEE_HEAVY_WINDUP;

    var _frame = floor(image_index);

    // Strike lands on the authored mask frames (14-16 of 22)
    if (_frame >= MELEE_HEAVY_STRIKE_FRAME && _frame <= MELEE_HEAVY_STRIKE_END) {
        if (!instance_exists(attack_hitbox)) {
            attack_hitbox = instance_create_layer(x, y, layer, obj_enemy_melee_hitbox);
        }
        attack_hitbox.x = x;
        attack_hitbox.y = y;
        attack_hitbox.sprite_index = spr_melee_enemy_heavy_attack_hb;
        attack_hitbox.image_index = image_index;
        attack_hitbox.image_xscale = facing_dir;
        attack_hitbox.owner = id;
        attack_hitbox.damage = MELEE_HEAVY_DAMAGE;   // 25, type HEAVY (PRD 7.2)
        attack_hitbox.unblockable = true;            // full damage through guard
    } else if (instance_exists(attack_hitbox)) {
        instance_destroy(attack_hitbox);
        attack_hitbox = noone;
    }

    // --- END OF COMMITMENT ---
    // Play the full animation out (no abort, even at the last frame).
    if (image_index >= image_number - 1) {
        heavy_attack_locked = false;

        if (instance_exists(attack_hitbox)) {
            instance_destroy(attack_hitbox);
            attack_hitbox = noone;
        }

        // A poise break earned mid-heavy is deferred, not cancelled (PRD 6.4):
        // the stagger begins the moment the heavy attack's recovery ends.
        if (poise_break_deferred) {
            poise_break_deferred = false;
            scr_enemy_stun(stun_duration);
        } else {
            attack_cooldown = MELEE_HEAVY_COOLDOWN;

            if (instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) <= sight_range) {
                state = enemy_states.run;
            } else {
                state = enemy_states.walk;
            }
        }
    }
}
