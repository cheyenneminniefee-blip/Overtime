/// scr_player_heavy_attack — the greatsword commitment (PRD 5.8)
/// Entered by holding the attack button past HEAVY_HOLD_THRESHOLD (the point
/// of no return in obj_player Step). Once here:
///   - rooted: hspd forced to 0, every input ignored (dodge/guard/jump/blocks
///     are gated out in Step; nothing can cancel this state)
///   - damage taken does not flinch, stagger, stun, or knock back
///     (armor handled in scr_player_take_damage)
///   - the body sprite plays the full authored 18-frame animation; the
///     hitbox mirrors image_index 1:1 (both sprites are authored 18 frames —
///     PRD 11.3 hitbox rects per sprite frame), with mask content on frames
///     8-12, so inactive frames just have empty masks and whiff; hit_list
///     makes the sweep hit every target in its arc (PRD greatsword hit cap)
///   - spear/mace will add their commit windows or swap this body via the
///     heavy_weapon slot later — keep this script greatsword-scoped
function scr_player_heavy_attack() {
    sprite_index = spr_player_attack_greatsword;
    image_speed = 1;

    normal_map = spr_player_attack_greatsword_nm;

    hspd = 0;   // PRD 5.8: locked in — rooted

    // Lower half: player is rooted, so idle legs (drawn under the swing like
    // every other attack)
    legs_sprite_index = spr_player_legs_idle;
    legs_image_index = 0;
    legs_image_speed = 0;

    // --- HITBOX ---
    if (attack_hitbox == noone) {
        attack_hitbox = instance_create_layer(x, y, layer, obj_player_hitbox);
        attack_hitbox.damage = GREATSWORD_DAMAGE;   // 40 (PRD 5.8)
        attack_hitbox.poise_mult = GREATSWORD_POISE;   // 2x poise (PRD 5.8)
    }
    if (instance_exists(attack_hitbox)) {
        attack_hitbox.x = x;
        attack_hitbox.y = y;
        attack_hitbox.sprite_index = spr_player_attack_greatsword_hb;
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
