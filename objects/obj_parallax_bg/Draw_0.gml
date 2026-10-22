// Resolve sprites on the first frame
if (!_built) scr_parallax_build();

var _cam = view_camera[0];
if (_cam == -1) exit;

var _cx = camera_get_view_x(_cam);
var _cy = camera_get_view_y(_cam);
var _vw = camera_get_view_width(_cam);
var _vh = camera_get_view_height(_cam);

// Furthest layer first
for (var i = array_length(layers) - 1; i >= 0; i--) {
    var _L = layers[i];

    // --- HORIZONTAL WRAP (unchanged) ---
    var _px = _cx * _L.fac;
    var _dx = _cx - _px + floor(_px / _L.w) * _L.w;

    // --- VERTICAL PLACEMENT: one copy, never loops ---
    // Start from the vertical parallax position...
    var _dy = _cy - (_cy * _L.vfac) + y_offset + _L.yoff;

    // ...then clamp so this single copy always covers the view top-to-bottom.
    // With 720-tall sprites on a 720-tall camera, the clamp pins the layer
    // to the screen — the horizon simply never moves vertically (the classic
    // platformer look: sky glued in place while you jump).
    // If you later make sprites TALLER than the view (e.g. 2560 x 1440),
    // vertical parallax engages automatically — and the clamp still
    // guarantees neither a gap nor a repeat can ever appear.
    _dy = clamp(_dy, _cy + _vh - _L.h, _cy);

    // Tile horizontally only
    while (_dx < _cx + _vw) {
        draw_sprite_ext(_L.spr, 0, _dx, _dy, 1, 1, 0, c_white, 1);
        _dx += _L.w;
    }
}