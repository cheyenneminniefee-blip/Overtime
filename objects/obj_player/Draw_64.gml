/// obj_player — Draw GUI: health (top-left, segmented), Overtime countdown
/// (top-center), stamina (amber) and energy (cyan) meters (bottom-left)
var _gh = display_get_gui_height();
var _gw = display_get_gui_width();
var _margin = 16;
var _gap = 20;
var _scale =3;

// --- OVERTIME COUNTDOWN (PRD 5.1: replaces the HP bar, top-center) ---
if (is_overtime) {
    var _ot_low = (overtime_timer < 300);   // pulse red below 5 s
    draw_set_color(_ot_low ? c_red : c_white);
    draw_set_alpha(_ot_low ? 0.55 + 0.45 * sin(overtime_timer * 0.5) : 1);
    draw_set_halign(fa_center);
    draw_text_transformed(_gw / 2, _margin, "OVERTIME  " + string_format(overtime_timer / 60, 0, 1), 2, 2, 0);
    draw_set_halign(fa_left);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// --- HP BAR (PRD 12.1: top-left, segmented 25 HP per segment) ---
if (!is_overtime) {
    var _hbw = sprite_get_width(spr_health_border);
    var _hxoff = sprite_get_xoffset(spr_health_border);
    var _hyoff = sprite_get_yoffset(spr_health_border);
    var _hinner_w = _hbw - 2 * _hxoff;
    var _hinner_h = sprite_get_height(spr_health_border) - 2 * _hyoff;
    var _hfill_h = sprite_get_height(spr_health);

    var _segs = hp_max / HEALTH_SEGMENT;
    var _seg_gap = 4;
    var _seg_w = (_hinner_w * _scale - (_segs - 1) * _seg_gap) / _segs;

    for (var _si = 0; _si < _segs; _si++) {
        var _seg_fill = clamp(hp - _si * HEALTH_SEGMENT, 0, HEALTH_SEGMENT) / HEALTH_SEGMENT;
        draw_sprite_ext(spr_health, 0, _margin + _si * (_seg_w + _seg_gap), _margin,
            _seg_w * _seg_fill, (_hinner_h / _hfill_h) * _scale, 0, c_white, 1);
    }
    draw_sprite_ext(spr_health_border, 0, _margin, _margin, _scale, _scale, 0, c_white, 1);
}

// Border geometry: the border's origin sits on its inner fill area's top-left,
// so drawing both sprites at the same anchor point aligns them (PRD HUD setup)
var _bw = sprite_get_width(spr_stamina_border);
var _bh = sprite_get_height(spr_stamina_border);
var _bxoff = sprite_get_xoffset(spr_stamina_border);
var _byoff = sprite_get_yoffset(spr_stamina_border);
var _inner_w = _bw - 2 * _bxoff;
var _inner_h = _bh - 2 * _byoff;
var _fill_h = sprite_get_height(spr_stamina);

// Anchor by the border's visible bottom edge (origin sits inside the sprite)
var _vis_h = (_bh - _byoff) * _scale;

// Energy sits at the very bottom-left; stamina stacks above it
var _ey = _gh - _margin - _vis_h;
var _sy = _ey - _gap - _vis_h;

// --- STAMINA (amber) — fill first, border on top ---
var _sratio = stamina / stamina_max;
draw_sprite_ext(spr_stamina, 0, _margin, _sy, _sratio * _inner_w * _scale, (_inner_h / _fill_h) * _scale, 0, c_white, 1);
draw_sprite_ext(spr_stamina_border, 0, _margin, _sy, _scale, _scale, 0, c_white, 1);

// --- ENERGY (cyan) — fill first, border on top ---
// PRD 12.1: hidden until the first energy unlock (has_phase_slash OR
// has_freeze) — Act 1 never shows a dead meter; the bar appears at the
// L6 Phase Slash pickup
if (has_phase_slash || has_freeze) {
    var _eratio = energy / energy_max;
    draw_sprite_ext(spr_energy, 0, _margin, _ey, _eratio * _inner_w * _scale, (_inner_h / _fill_h) * _scale, 0, c_white, 1);
    draw_sprite_ext(spr_energy_border, 0, _margin, _ey, _scale, _scale, 0, c_white, 1);

    // --- FREEZE FIZZLE (PRD 5.2: rejected activation pulses the meter) ---
    // Icy-blue pulse over the energy border — the freeze-associated hue, not the
    // damage flash (PRD 12.3)
    if (freeze_fizzle_timer > 0) {
        var _fizzle_alpha = 0.5 + 0.5 * sin(freeze_fizzle_timer * 1.5);
        draw_sprite_ext(spr_energy_border, 0, _margin, _ey, _scale, _scale, 0, FREEZE_TINT, _fizzle_alpha);
    }
}

// --- GRENADE PIPS (PRD 12.1: bottom-left, under stamina) ---
// Drawn in the gap between the stamina and energy bars, centered vertically
if (has_grenades) {
    var _pip_y = _sy + _vis_h + 10;   // midpoint of the 20 px gap
    for (var _i = 0; _i < grenades_max; _i++) {
        var _pip_alpha = (_i < grenades) ? 1 : 0.25;
        draw_sprite_ext(spr_grenade, 0, _margin + 8 + _i * 20, _pip_y, 2, 2, 0, c_white, _pip_alpha);
    }
}

// --- FREEZE ICON (PRD 12.1: bottom-right; lights only when Freeze is ready) ---
// Ready = energy at exactly full AND the 30 s cooldown clear AND not already
// frozen (PRD 5.2). Unlit otherwise. The ready glow doubles as the meter cue,
// and its flash doubles as the fizzle feedback (12.3: sound + icon, not hue).
var _iw = sprite_get_width(spr_freeze_icon) * 2;
var _ih = sprite_get_height(spr_freeze_icon) * 2;
var _icon_ready = (energy >= energy_max)
    && instance_exists(obj_time_domain)
    && obj_time_domain.freeze_cd_timer <= 0
    && (global.time_state == TIME.RUN);
var _icon_x = _gw - _margin - _iw / 2;
var _icon_y = _gh - _margin - _ih / 2;
if (_icon_ready) {
    var _ready_pulse = 0.75 + 0.25 * sin(current_time / 150);   // gentle ready cue
    draw_sprite_ext(spr_freeze_icon, 0, _icon_x, _icon_y, 2, 2, 0, FREEZE_TINT, _ready_pulse);
} else {
    draw_sprite_ext(spr_freeze_icon, 0, _icon_x, _icon_y, 2, 2, 0, c_dkgray, 0.3);
}

// --- PHASE SLASH ICON + COOLDOWN SWEEP (PRD 12.1: bottom-right, one slot
// left of the Freeze icon) --- Lit violet when the 2 s recharge is clear AND
// the teleport is affordable; while recharging, a dark veil covers the
// remaining-cooldown share of the icon from the top and recedes as it
// refills, with an accent line at the sweep edge. Dim gray when recharged
// but too low on energy (same "not ready" read as the unlit Freeze icon).
var _pw = sprite_get_width(spr_phase_cooldown_icon) * 2;
var _ph = sprite_get_height(spr_phase_cooldown_icon) * 2;
var _ps_x = _icon_x - _iw - 8;   // keep the same baseline as the Freeze icon
var _ps_top = _icon_y - _ph / 2;
if (phase_slash_cooldown <= 0 && energy >= phase_slash_cost) {
    draw_sprite_ext(spr_phase_cooldown_icon, 0, _ps_x, _icon_y, 2, 2, 0, PHASE_TINT, 1);
} else {
    draw_sprite_ext(spr_phase_cooldown_icon, 0, _ps_x, _icon_y, 2, 2, 0, c_dkgray, 0.3);
    if (phase_slash_cooldown > 0) {
        var _rfrac = clamp(phase_slash_cooldown / phase_slash_cd_max, 0, 1);
        var _veil_h = _ph * _rfrac;
        draw_set_color(c_black);
        draw_set_alpha(0.65);
        draw_rectangle(_ps_x - _pw / 2, _ps_top, _ps_x + _pw / 2, _ps_top + _veil_h, false);
        if (_veil_h > 0 && _veil_h < _ph) {
            draw_set_color(PHASE_TINT);
            draw_set_alpha(0.9);
            draw_rectangle(_ps_x - _pw / 2, _ps_top + _veil_h - 2, _ps_x + _pw / 2, _ps_top + _veil_h, false);
        }
        draw_set_alpha(1);
        draw_set_color(c_white);
    }
}
