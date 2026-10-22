/// scr_tpl_check_edge(_cg, _col, _floor_row, _open, _above)
// Unified edge rule. Returns the first invalid row, or -1 if the edge is sound.
//   OPEN edge:   solid from the floor row DOWN to row 22 (no gap under the
//                connection), clear at rows F-3..F-1 (3-tile passage).
//                Below-biome also requires solid above the passage (enclosed).
//   SEALED edge: solid the full column (cliff face).
function scr_tpl_check_edge(_cg, _col, _floor_row, _open, _above) {
    if (_open) {
        for (var _r = _floor_row; _r <= FLOOR_BOTTOM; _r++) {
            if (!_cg[_r * CHUNK_W + _col]) return _r;
        }
        for (var _r2 = _floor_row - 3; _r2 <= _floor_row - 1; _r2++) {
            if (_cg[_r2 * CHUNK_W + _col]) return _r2;
        }
        if (!_above) {
            for (var _r3 = 0; _r3 <= _floor_row - 4; _r3++) {
                if (!_cg[_r3 * CHUNK_W + _col]) return _r3;
            }
        }
    } else {
        for (var _r4 = 0; _r4 <= FLOOR_BOTTOM; _r4++) {
            if (!_cg[_r4 * CHUNK_W + _col]) return _r4;
        }
    }
    return -1;
}