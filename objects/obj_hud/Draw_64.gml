/// obj_hud — Draw GUI: stamina (amber, top) and energy (cyan) meters, bottom-left
if (!instance_exists(obj_player)) exit;

var _p = obj_player;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _margin = 16;
var _gap = 6;

// Border geometry: the border's origin sits on its inner fill area's top-left
var _bw = sprite_get_width(spr_stamina_border);
var _bh = sprite_get_height(spr_stamina_border);
var _bxoff = sprite_get_xoffset(spr_stamina_border);
var _byoff = sprite_get_yoffset(spr_stamina_border);
var _inner_w = _bw - 2 * _bxoff;
var _inner_h = _bh - 2 * _byoff;
var _fill_h = sprite_get_height(spr_stamina);

// Energy sits at the very bottom-left; stamina stacks above it
var _ey = _gh - _margin - _bh;
var _sy = _ey - _gap - _bh;

// --- STAMINA (amber) ---
draw_sprite(spr_stamina_border, 0, _margin + _bxoff, _sy + _byoff);
var _sratio = _p.stamina / _p.stamina_max;
draw_sprite_ext(spr_stamina, 0, _margin, _sy, _sratio * _inner_w, _inner_h / _fill_h, 0, c_white, 1);

// --- ENERGY (cyan) ---
draw_sprite(spr_energy_border, 0, _margin + _bxoff, _ey + _byoff);
var _eratio = _p.energy / _p.energy_max;
draw_sprite_ext(spr_energy, 0, _margin, _ey, _eratio * _inner_w, _inner_h / _fill_h, 0, c_white, 1);
