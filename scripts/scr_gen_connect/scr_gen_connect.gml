/// scr_gen_connect(_grid, _x1, _y1, _x2, _y2) — activate neighbor + set door
// flags on BOTH cells
function scr_gen_connect(_grid, _x1, _y1, _x2, _y2) {
    var _dx = _x2 - _x1;
    var _dy = _y2 - _y1;
    var _a = _grid[_x1][_y1];
    var _b = _grid[_x2][_y2];
    if (_dx == 1)  { _a.r = true; _b.l = true; }
    if (_dx == -1) { _a.l = true; _b.r = true; }
    if (_dy == 1)  { _a.d = true; _b.u = true; }
    if (_dy == -1) { _a.u = true; _b.d = true; }
    _b.active = true;
}