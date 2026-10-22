/// scr_tpl_export(_cx, _cy) — read one workshop chunk into a template struct.
// ART: raw tile data from the "Tiles_workshop" layer (flips/mirrors survive).
// COLLISION: harvested from the obj_solid_tile instances you placed.
// DOORS: declared in the header's tpl_doors string, then validated.
function scr_tpl_export(_cx, _cy) {
    var _tm  = layer_tilemap_get_id(layer_get_id("Tiles_workshop"));
    var _x0  = _cx * CHUNK_PITCH_W;
    var _y0  = _cy * CHUNK_PITCH_H;
    var _px0 = _cx * CHUNK_PITCH_W_PX;
    var _py0 = _cy * CHUNK_PITCH_H_PX;
    var _px1 = _px0 + CHUNK_W_PX;
    var _py1 = _py0 + CHUNK_H_PX;

    // --- 1. ART: raw tile data ---
    var _art = array_create(CHUNK_W * CHUNK_H, 0);
    for (var _row = 0; _row < CHUNK_H; _row++) {
        for (var _col = 0; _col < CHUNK_W; _col++) {
            _art[_row * CHUNK_W + _col] = tilemap_get(_tm, _x0 + _col, _y0 + _row);
        }
    }

    // --- 2. COLLISION GRID: mark every cell covered by a workshop solid ---
    // (Handles scaled instances; an instance straddling a chunk boundary
    // contributes its cells to BOTH chunks — nothing is lost or duplicated)
    var _cg = array_create(CHUNK_W * CHUNK_H, 0);
    with (obj_solid_tile) {
        if (bbox_right < _px0 || bbox_left >= _px1) continue;
        if (bbox_bottom < _py0 || bbox_top >= _py1) continue;
        var _c0 = max(0, floor((bbox_left   - _px0) / TILE_SIZE));
        var _c1 = min(CHUNK_W - 1, floor((bbox_right  - _px0) / TILE_SIZE));
        var _r0 = max(0, floor((bbox_top    - _py0) / TILE_SIZE));
        var _r1 = min(CHUNK_H - 1, floor((bbox_bottom - _py0) / TILE_SIZE));
        for (var _rr = _r0; _rr <= _r1; _rr++) {
            for (var _cc = _c0; _cc <= _c1; _cc++) {
                _cg[_rr * CHUNK_W + _cc] = 1;
            }
        }
    }

    // --- 3. HEADER + MARKERS ---
    var _name = ""; var _biome = ""; var _tags = []; var _doors = ""; var _markers = [];
    with (obj_tpl_header) {
        if (x >= _px0 && x < _px1 && y >= _py0 && y < _py1) {
            _name = tpl_name; _biome = tpl_biome; _tags = tpl_tags; _doors = tpl_doors;
        }
    }
    with (obj_tpl_marker) {
        if (x >= _px0 && x < _px1 && y >= _py0 && y < _py1) {
            array_push(_markers, { type: tag, tx: floor((x - _px0) / TILE_SIZE), ty: floor((y - _py0) / TILE_SIZE) });
        }
    }
    if (_name == "") {
        show_debug_message("scr_tpl_export: chunk (" + string(_cx) + ", " + string(_cy) +
                           ") has no obj_tpl_header — skipped.");
        return noone;
    }
	
	    // --- 3.5 EDGE FLOOR MARKERS ---
    // Convention: the marker sits ON the ground tile at the edge column;
    // its row IS that edge's ground top row. Absent marker = 21 (dormant).
    var _fl = 21; var _fr = 21;
    var _fl_set = false; var _fr_set = false;
    with (obj_tpl_floor) {
        if (x >= _px0 && x < _px1 && y >= _py0 && y < _py1) {
            var _tx = floor((x - _px0) / TILE_SIZE);
            var _ty = floor((y - _py0) / TILE_SIZE);
            if (_tx <= 1 && !_fl_set) {
                _fl = _ty; _fl_set = true;
            } else if (_tx >= CHUNK_W - 2 && !_fr_set) {
                _fr = _ty; _fr_set = true;
            } else if (_tx > 1 && _tx < CHUNK_W - 2) {
                show_debug_message("TEMPLATE '" + _name + "' — floor marker not on an edge column (ignored)");
            }
        }
    }

    // --- 4. PARSE THE DECLARED DOORS ---
    var _ds = string_upper(_doors);
    var _dl = (string_pos("L", _ds) > 0);
    var _dr = (string_pos("R", _ds) > 0);
    var _du = (string_pos("U", _ds) > 0);
    var _dd = (string_pos("D", _ds) > 0);

    // --- 5. VALIDATION ---
    var _warn = "";

    // 5a. Declared doors must be physically open
    if (_dl) {
        for (var _r = DOOR_ROW_TOP; _r <= DOOR_ROW_BOT; _r++) {
            if (_cg[_r * CHUNK_W]) { _warn += "Declared L door is blocked at row " + string(_r) + ". "; break; }
        }
    }
    if (_dr) {
        for (var _r = DOOR_ROW_TOP; _r <= DOOR_ROW_BOT; _r++) {
            if (_cg[_r * CHUNK_W + CHUNK_W - 1]) { _warn += "Declared R door is blocked at row " + string(_r) + ". "; break; }
        }
    }
    if (_du) {
        for (var _r = 0; _r <= CEIL_BOTTOM; _r++) {
            if (_cg[_r * CHUNK_W + DOOR_COL_A] || _cg[_r * CHUNK_W + DOOR_COL_B]) {
                _warn += "Declared U door is blocked at row " + string(_r) + ". "; break;
            }
        }
    }
    if (_dd) {
        for (var _r = FLOOR_TOP; _r <= FLOOR_BOTTOM; _r++) {
            if (_cg[_r * CHUNK_W + DOOR_COL_A] || _cg[_r * CHUNK_W + DOOR_COL_B]) {
                _warn += "Declared D door is blocked at row " + string(_r) + ". "; break;
            }
        }
    }

    // 5b. EDGE VALIDATION (height-aware, biome-aware)
    var _above = (_biome == "above");
    if (!_above && (_fl != 21 || _fr != 21)) {
        _warn += "Below-biome chunks must use the standard floor (21). ";
        _fl = 21; _fr = 21;
    }
    if (_fl_set && !_dl) _warn += "Floor marker on a sealed LEFT edge — declare the door or remove it. ";
    if (_fr_set && !_dr) _warn += "Floor marker on a sealed RIGHT edge — declare the door or remove it. ";

    var _bl = scr_tpl_check_edge(_cg, 0, _fl, _dl, _above);
    if (_bl != -1) _warn += "LEFT edge invalid at row " + string(_bl) +
        " (open edge: solid below the floor row, clear 3-tile passage above it; sealed edge: full cliff). ";
    var _br = scr_tpl_check_edge(_cg, CHUNK_W - 1, _fr, _dr, _above);
    if (_br != -1) _warn += "RIGHT edge invalid at row " + string(_br) + " (same rules). ";

    // 5c. BOTTOM SEAL: row 22 solid everywhere except declared D-door columns.
    // (Pits and trenches bottom out ON row 22; the only way through a chunk's
    // bottom is a declared D door.)
    for (var _c = 0; _c < CHUNK_W; _c++) {
        if (_dd && (_c == DOOR_COL_A || _c == DOOR_COL_B)) continue;
        if (!_cg[FLOOR_BOTTOM * CHUNK_W + _c]) {
            _warn += "Row 22 open at col " + string(_c) + " — seal it or declare a D door. ";
            break;
        }
    }
    // --- 6. PACKAGE ---
    return {
        name:      _name,
        biome:     _biome,
        tags:      _tags,
        doors:     { l: _dl, r: _dr, u: _du, d: _dd },
        art:       _art,
        collision: _cg,
        markers:   _markers,
        floor_l:   _fl,
        floor_r:   _fr
    };
}