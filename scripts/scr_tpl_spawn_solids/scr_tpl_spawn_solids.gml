/// scr_tpl_spawn_solids(_tpl, _chunk_x, _chunk_y) — physics for one cell.
// Every unbroken horizontal run of collision cells becomes ONE instance, so
// however you placed solids in the workshop, the level gets the merged
// minimum instance count.
function scr_tpl_spawn_solids(_tpl, _chunk_x, _chunk_y) {
    var _ox = _chunk_x * CHUNK_W_PX;
    var _oy = _chunk_y * CHUNK_H_PX;

    for (var _row = 0; _row < CHUNK_H; _row++) {
        var _run = 0;
        for (var _col = 0; _col <= CHUNK_W; _col++) {
            var _solid = (_col < CHUNK_W) && (_tpl.collision[_row * CHUNK_W + _col] == 1);
            if (_solid) {
                _run++;
            } else if (_run > 0) {
                scr_spawn_solid_rect(_ox + (_col - _run) * TILE_SIZE,
                                     _oy +  _row        * TILE_SIZE,
                                     _run, 1);
                _run = 0;
            }
        }
    }
}