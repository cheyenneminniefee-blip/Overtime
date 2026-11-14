/// obj_player — Draw GUI: stamina (amber, top) and energy (cyan) meters, bottom-left
var _gh = display_get_gui_height();
var _margin = 16;
var _gap = 6;
var _scale = 5;

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
var _eratio = energy / energy_max;
draw_sprite_ext(spr_energy, 0, _margin, _ey, _eratio * _inner_w * _scale, (_inner_h / _fill_h) * _scale, 0, c_white, 1);
draw_sprite_ext(spr_energy_border, 0, _margin, _ey, _scale, _scale, 0, c_white, 1);
