/// scr_tilemap_fill(_tm, _index) — fill a whole tilemap with one tile index.
// Compatibility replacement for the built-in tilemap_fill(), which only
// exists in newer GameMaker runtimes. Assumes the tilemap covers the full
// room — true for every tile layer in this project (Room Editor tile
// layers default to room-sized).
function scr_tilemap_fill(_tm, _index) {
    var _cols = room_width div TILE_SIZE;
    var _rows = room_height div TILE_SIZE;
    for (var _r = 0; _r < _rows; _r++) {
        for (var _c = 0; _c < _cols; _c++) {
            tilemap_set(_tm, _index, _c, _r);
        }
    }
}