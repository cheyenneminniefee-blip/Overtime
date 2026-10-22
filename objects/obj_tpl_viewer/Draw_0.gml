// Collision overlay: red = solid. Compare against the stamped art above it.
if (!variable_global_exists("templates") || array_length(global.templates) == 0) exit;

var _t = global.templates[tpl_index];
draw_set_alpha(0.35);
draw_set_color(c_red);
for (var _r = 0; _r < CHUNK_H; _r++) {
    for (var _c = 0; _c < CHUNK_W; _c++) {
        if (_t.collision[_r * CHUNK_W + _c]) {
            draw_rectangle(_c * TILE_SIZE, _r * TILE_SIZE,
                           (_c + 1) * TILE_SIZE - 1, (_r + 1) * TILE_SIZE - 1, false);
        }
    }
}
draw_set_alpha(1);