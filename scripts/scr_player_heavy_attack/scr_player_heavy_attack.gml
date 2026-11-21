/// scr_player_heavy_attack — the committed heavy weapon (PRD 5.8)
/// Entered by holding the attack button past HEAVY_HOLD_THRESHOLD (the point
/// of no return in obj_player Step). Once here:
///   - rooted: hspd forced to 0, every input ignored (dodge/guard/jump/blocks
///     are gated out in Step; nothing can cancel this state)
///   - damage taken does not flinch, stagger, stun, or knock back
///     (armor handled in scr_player_take_damage)
///   - the body sprite plays the full authored animation; the hitbox mirrors
///     image_index 1:1 (body and _hb sprites are authored frame-aligned —
///     PRD 11.3 hitbox rects per sprite frame), so inactive frames just have
///     empty masks and whiff; hit_list makes the sweep hit per the weapon's
///     PRD 5.8 hit cap (spear 2, everything else arc-wide)
/// Dispatches on heavy_weapon (the L6 armory choice); mace will slot into the
/// switch below with its overhead + stun wave when its sprites land.
function scr_player_heavy_attack() {

    // --- PER-WEAPON LOADOUT (PRD 5.8 table) ---
    switch (heavy_weapon) {
        case WEAPON.SPEAR: {
            sprite_index = spr_player_attack_spear;
            normal_map   = spr_player_attack_spear_nm;
            _hb_sprite   = spr_player_attack_spear_hb;
            _dmg         = SPEAR_DAMAGE;          // 35
            _poise       = SPEAR_POISE;           // 1.5x
            _max_targets = SPEAR_MAX_TARGETS;     // pierces up to 2
            break;
        }
        case WEAPON.GREATSWORD:
        default: {
            sprite_index = spr_player_attack_greatsword;
            normal_map   = spr_player_attack_greatsword_nm;
            _hb_sprite   = spr_player_attack_greatsword_hb;
            _dmg         = GREATSWORD_DAMAGE;     // 40
            _poise       = GREATSWORD_POISE;      // 2x
            _max_targets = HB_TARGETS_UNLIMITED;  // hits every target in its arc
            break;
        }
    }

    image_speed = scr_dt();

    hspd = 0;   // PRD 5.8: locked in — rooted

    // Lower half: the authored 254x254 bodies carry their own legs (Draw_0
    // suppresses the legs layer during heavy_attack), but keep the legs
    // system neutralized anyway for safety
    legs_sprite_index = spr_player_legs_idle;
    legs_image_index = 0;
    legs_image_speed = 0;

    // --- HITBOX ---
    if (attack_hitbox == noone) {
        attack_hitbox = instance_create_layer(x, y, layer, obj_player_hitbox);
        attack_hitbox.damage = _dmg;
        attack_hitbox.poise_mult = _poise;
        attack_hitbox.max_targets = _max_targets;
    }
    if (instance_exists(attack_hitbox)) {
        attack_hitbox.x = x;
        attack_hitbox.y = y;
        attack_hitbox.sprite_index = _hb_sprite;
        attack_hitbox.image_index = image_index;
        attack_hitbox.image_xscale = facing_dir;
    }

    // --- END OF COMMITMENT ---
    // Play the full animation out (no abort, even at the last frame). The
    // final frame holds for one step, then the state clears to idle.
    if (image_index >= image_number - 1) {
        if (instance_exists(attack_hitbox)) {
            instance_destroy(attack_hitbox);
        }
        attack_hitbox = noone;
        attack_cooldown = 5;
        state = player_states.idle;
    }
}
