/// scr_tpl_stamp(_tpl, _chunk_x, _chunk_y) — art + physics for one cell.
// Art writes RAW tile data, so flips/mirrors survive. The runtime tile layer
// must use the SAME tileset as the workshop layer or indices point at
// the wrong art.
function scr_tpl_stamp(_tpl, _chunk_x, _chunk_y) {
    var _tm = layer_tilemap_get_id(layer_get_id("Tiles_runtime"));
    var _ox = _chunk_x * CHUNK_W;
    var _oy = _chunk_y * CHUNK_H;

    for (var _row = 0; _row < CHUNK_H; _row++) {
        for (var _col = 0; _col < CHUNK_W; _col++) {
            var _data = _tpl.art[_row * CHUNK_W + _col];
            if (_data != 0) {
                tilemap_set(_tm, _data, _ox + _col, _oy + _row);
            }
        }
    }

    scr_tpl_spawn_solids(_tpl, _chunk_x, _chunk_y);
}