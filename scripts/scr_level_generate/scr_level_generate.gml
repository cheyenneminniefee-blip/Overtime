/// scr_level_generate(_surface_biome, _main_len, _seed)
// Primarily-horizontal generation: a forward-weighted walk across a surface
// band, with bounded "dips" underground. Entrance left, exit far right,
// both on the surface. Inactive cells fill as rock below the ground line
// and as earth columns above underground rooms (surface mesas).
function scr_level_generate(_surface_biome, _main_len, _seed) {
    random_set_seed(_seed);

    var _gw = GEN_GRID_W;
    var _gh = GEN_GRID_H;
    var _cave_biome = "below";
    var _offs = [[1, 0], [-1, 0], [0, 1], [0, -1]];   // right, left, down, up

    // --- WALK TUNING ---
    var _dive_chance     = 0.5;    // per-step chance to dive when eligible
    var _min_surface_gap = 4;      // surface cells required between dips
    var _max_dips        = 2;      // "a few underground sections"
    var _w_right_surface = 5.0;    // strong forward pull on the surface
    var _w_right_under   = 4.0;
    var _w_left          = 0.2;    // rare organic backtracks
    var _w_vert_surface  = 1.2;    // high-road/low-road jogs
    var _w_vert_under    = 0.9;    // cave jogs between rows 4-6

    // --- 1. GRID INIT ---
    var _grid = [];
    for (var _i = 0; _i < _gw; _i++) {
        _grid[_i] = [];
        for (var _j = 0; _j < _gh; _j++) {
            _grid[_i][_j] = {
                active: false, role: "",
                l: false, r: false, u: false, d: false,
                tpl: noone
            };
        }
    }

    // --- 2. THE WALK ---
    // Entrance: left edge, middle surface row. First step forced right so
    // the entrance cell's mask is always exactly R.
    var _x = 1;
    var _y = 2;
    _grid[_x][_y].active = true;
    _grid[_x][_y].role   = "entrance";

    var _path = [[_x, _y]];
    scr_gen_connect(_grid, _x, _y, _x + 1, _y);
    _grid[_x + 1][_y].role = "main";
    array_push(_path, [_x + 1, _y]);
    _x += 1;
    var _count = 2;

    var _mode       = "surface";   // "surface" | "under"
    var _since_dive = 1;
    var _under_run  = 0;
    var _dip_target = 0;
    var _dips       = 0;
    var _guard      = 0;

    // Keep walking until the room count is met AND we're back on the
    // surface — the exit is never underground.
    while ((_count < _main_len || _y >= GROUND_LINE) && _guard < 2000) {
        _guard++;

        var _exiting = (_mode == "under" && _under_run >= _dip_target);
        var _cands = [];
        var _wts   = [];

        for (var _k = 0; _k < 4; _k++) {
            var _nx = _x + _offs[_k][0];
            var _ny = _y + _offs[_k][1];
            if (_nx < 1 || _nx >= _gw - 1) continue;   // 1-cell border
            if (_ny < 1 || _ny >= _gh - 1) continue;
            if (_grid[_nx][_ny].active)    continue;

            var _wt = 0;
            if (_k == 0) {                                   // RIGHT
                _wt = (_mode == "surface") ? _w_right_surface : _w_right_under;
            } else if (_k == 1) {                            // LEFT
                _wt = _w_left;
            } else if (_k == 2) {                            // DOWN
                if (_mode == "surface") {
                    if (_ny >= GROUND_LINE) {
                        // Crossing the ground line is only the DIVE move
                        var _eligible = (_y == GROUND_LINE - 1)
                                     && (_since_dive >= _min_surface_gap)
                                     && (_dips < _max_dips);
                        if (_eligible && random(1) < _dive_chance) _wt = 100;
                    } else {
                        _wt = _w_vert_surface;   // jog to a lower surface row
                    }
                } else if (!_exiting) {
                    _wt = _w_vert_under;         // deeper cave rows
                }
            } else {                                         // UP
                if (_mode == "surface") {
                    _wt = _w_vert_surface;       // jog to a higher surface row
                } else if (_exiting) {
                    _wt = (_ny < GROUND_LINE) ? 100 : 3;   // the resurface
                } else if (_ny >= GROUND_LINE) {
                    _wt = _w_vert_under;         // can't surface mid-dip
                }
            }

            if (_wt <= 0) continue;
            array_push(_cands, [_nx, _ny]);
            array_push(_wts, _wt);
        }

        if (array_length(_cands) == 0) {
            // Trapped: prune the dead-end cell and step back
            if (array_length(_path) > 1) {
                var _prev = _path[array_length(_path) - 2];
                var _pv   = _grid[_prev[0]][_prev[1]];
                var _dead = _grid[_x][_y];
                if (_x == _prev[0] + 1)      { _dead.l = false; _pv.r = false; }
                else if (_x == _prev[0] - 1) { _dead.r = false; _pv.l = false; }
                else if (_y == _prev[1] + 1) { _dead.u = false; _pv.d = false; }
                else                         { _dead.d = false; _pv.u = false; }
                _dead.active = false;
                _dead.role   = "";
                array_delete(_path, array_length(_path) - 1, 1);
                _x = _prev[0];
                _y = _prev[1];
                _count--;

                // Recompute dive state from the new path tail
                _mode = (_y >= GROUND_LINE) ? "under" : "surface";
                _under_run  = 0;
                _since_dive = 0;
                var _ti = array_length(_path) - 1;
                while (_ti >= 0) {
                    var _py = _path[_ti][1];
                    if (_mode == "under"  && _py >= GROUND_LINE) _under_run++;
                    else if (_mode == "surface" && _py < GROUND_LINE) _since_dive++;
                    else break;
                    _ti--;
                }
                _dips = 0;
                for (var _di = 1; _di < array_length(_path); _di++) {
                    if (_path[_di][1] >= GROUND_LINE && _path[_di - 1][1] < GROUND_LINE) _dips++;
                }
            } else {
                break;
            }
            continue;
        }

        // Weighted pick
        var _total = 0;
        for (var _w = 0; _w < array_length(_wts); _w++) _total += _wts[_w];
        var _roll = random(_total);
        var _pick = array_length(_cands) - 1;
        for (var _w2 = 0; _w2 < array_length(_wts); _w2++) {
            _roll -= _wts[_w2];
            if (_roll <= 0) { _pick = _w2; break; }
        }

        var _nx2 = _cands[_pick][0];
        var _ny2 = _cands[_pick][1];
        var _crossed_down = (_y < GROUND_LINE && _ny2 >= GROUND_LINE);
        var _crossed_up   = (_y >= GROUND_LINE && _ny2 < GROUND_LINE);

        scr_gen_connect(_grid, _x, _y, _nx2, _ny2);
        _grid[_nx2][_ny2].role = "main";
        array_push(_path, [_nx2, _ny2]);
        _x = _nx2;
        _y = _ny2;
        _count++;

        if (_crossed_down) {
            _mode       = "under";
            _under_run  = 1;
            _dip_target = 2 + irandom(2);   // 2-4 cave cells before surfacing
            _dips++;
        } else if (_crossed_up) {
            _mode       = "surface";
            _since_dive = 1;
        } else if (_mode == "surface") {
            _since_dive++;
        } else {
            _under_run++;
        }
    }

    if (array_length(_path) > 1) {
        _grid[_x][_y].role = "exit";
    }

    // --- 3. SIDE BRANCHES (one-cell treasure dead-ends) ---
    // Note what this produces now: a branch DOWN from a row-3 surface cell
    // becomes a treasure CELLAR under the desert (a below-biome U room under
    // an above room's floor hole).
    for (var _b = 1; _b < array_length(_path) - 1; _b++) {
        if (random(1) > 0.35) continue;
        var _bx = _path[_b][0];
        var _by = _path[_b][1];

        var _bcands = [];
        for (var _k2 = 0; _k2 < 4; _k2++) {
            var _bnx = _bx + _offs[_k2][0];
            var _bny = _by + _offs[_k2][1];
            if (_bnx < 1 || _bnx >= _gw - 1) continue;
            if (_bny < 1 || _bny >= _gh - 1) continue;
            if (_grid[_bnx][_bny].active)    continue;
            array_push(_bcands, [_bnx, _bny]);
        }
        if (array_length(_bcands) == 0) continue;

        var _bpick  = irandom(array_length(_bcands) - 1);
        var _bcellx = _bcands[_bpick][0];
        var _bcelly = _bcands[_bpick][1];
        scr_gen_connect(_grid, _bx, _by, _bcellx, _bcelly);
        _grid[_bcellx][_bcelly].role = "bonus";
    }

    // --- 4. TEMPLATE ASSIGNMENT (biome by row; heights threaded in path order) ---
    var _was_connector = false;
    var _height = 21;   // running surface height of the horizontal chain
    for (var _p = 0; _p < array_length(_path); _p++) {
        var _cell = _grid[_path[_p][0]][_path[_p][1]];
        var _cb   = (_path[_p][1] < GROUND_LINE) ? _surface_biome : _cave_biome;
        var _dc   = scr_gen_door_count(_cell);
        var _tags = [];

        if (_cell.role == "entrance")      _tags = ["entrance"];
        else if (_cell.role == "exit")     _tags = ["exit"];
        else if (_dc == 2 && !_was_connector && random(1) < 0.5) _tags = ["connector"];
        else                               _tags = ["combat"];

        // Constrain the inlet only if this cell's LEFT edge is connected.
        // (After a vertical jog the inlet is sealed — the height naturally resets.)
        var _need_l = (_cell.l) ? _height : -1;
        _cell.tpl = scr_gen_assign(_cb, _cell, _tags, _need_l, -1);
        _was_connector = (_cell.tpl != noone && array_contains(_cell.tpl.tags, "connector"));

        // Carry the chain height out through this cell's right edge
        if (_cell.tpl != noone) _height = _cell.tpl.floor_r;
    }

    // Bonus cells: constrain against their already-assigned parent when the
    // branch attached horizontally; vertical branches are height-free
    for (var _gx = 0; _gx < _gw; _gx++) {
        for (var _gy = 0; _gy < _gh; _gy++) {
            var _bcell = _grid[_gx][_gy];
            if (!(_bcell.active && _bcell.role == "bonus")) continue;

            var _need_l = -1; var _need_r = -1;
            if (_bcell.l && _grid[_gx - 1][_gy].tpl != noone) _need_l = _grid[_gx - 1][_gy].tpl.floor_r;
            if (_bcell.r && _grid[_gx + 1][_gy].tpl != noone) _need_r = _grid[_gx + 1][_gy].tpl.floor_l;

            _bcell.tpl = scr_gen_assign(_gy < GROUND_LINE ? _surface_biome : _cave_biome,
                                        _bcell, ["treasure"], _need_l, _need_r);
        }
    }

    // --- 4.5 SEAM AUDIT ---
    // The forward threading covers the (overwhelmingly common) rightward chain;
    // this catches every horizontal connection in every direction.
    for (var _ax = 0; _ax < _gw - 1; _ax++) {
        for (var _ay = 0; _ay < _gh; _ay++) {
            var _a1 = _grid[_ax][_ay];
            var _a2 = _grid[_ax + 1][_ay];
            if (!_a1.active || !_a2.active || !_a1.r) continue;
            if (_a1.tpl == noone || _a2.tpl == noone) continue;
            if (abs(_a1.tpl.floor_r - _a2.tpl.floor_l) > 2) {
                show_debug_message("SEAM WARNING: unclimbable floor step (" +
                    string(_a1.tpl.floor_r) + " -> " + string(_a2.tpl.floor_l) +
                    ") between cells (" + string(_ax) + "," + string(_ay) + ") and (" +
                    string(_ax + 1) + "," + string(_ay) + ") — author a matching-height template.");
            }
        }
    }

    // --- 5. CLEAR + REGENERATION CLEANUP ---
    var _tm = layer_tilemap_get_id(layer_get_id("Tiles_runtime"));
    scr_tilemap_fill(_tm, 0);   // was: tilemap_fill(_tm, 0);

    with (obj_solid_tile)   instance_destroy();
    with (obj_enemy_parent) instance_destroy();
    with (obj_player)       instance_destroy();
    with (obj_tpl_marker)   instance_destroy();

    // --- 6. THE EARTH FILL ---
    // Pass A (bottom-up per column) computes the rock map:
    //   - inactive cells at/below the ground line are rock (the underground zone)
    //   - inactive cells above an underground room are rock too, propagating
    //     up to the sky (earth columns / surface mesas). Active cells break
    //     the column: a surface room resumes sky above it, a cave restarts
    //     earth above it.
    var _rock = [];
    for (var _fx = 0; _fx < _gw; _fx++) {
        _rock[_fx] = array_create(_gh, false);
        var _earth = false;
        for (var _fy = _gh - 1; _fy >= 0; _fy--) {
            var _fc = _grid[_fx][_fy];
            if (_fc.active) {
                _earth = (_fy >= GROUND_LINE);
            } else if (_fy >= GROUND_LINE || _earth) {
                _rock[_fx][_fy] = true;
            }
        }
    }

    // Pass B stamps the art (top-edge variant on exposed rock tops) and one
    // merged collider per vertical run per column.
    for (var _fx = 0; _fx < _gw; _fx++) {
        var _run = 0;
        for (var _fy = 0; _fy <= _gh; _fy++) {
            var _isrock = (_fy < _gh) && _rock[_fx][_fy];

            if (_isrock) {
                _run++;
                var _exposed = (_fy == 0) || !_rock[_fx][_fy - 1];
                for (var _r = 0; _r < CHUNK_H; _r++) {
                    var _idx = (_exposed && _r == 0) ? ROCK_TOP_TILE_INDEX : ROCK_TILE_INDEX;
                    for (var _c = 0; _c < CHUNK_W; _c++) {
                        tilemap_set(_tm, _idx, _fx * CHUNK_W + _c, _fy * CHUNK_H + _r);
                    }
                }
            } else if (_run > 0) {
                scr_spawn_solid_rect(_fx * CHUNK_W_PX, (_fy - _run) * CHUNK_H_PX,
                                     CHUNK_W, _run);
                _run = 0;
            }
        }
    }

    // --- 7. STAMP ACTIVE CELLS + SPAWN CONTENT ---
    var _rooms   = 0;
    var _missing = 0;

    for (var _sx = 0; _sx < _gw; _sx++) {
        for (var _sy = 0; _sy < _gh; _sy++) {
            var _scell = _grid[_sx][_sy];
            if (!_scell.active) continue;

            // --- 7a. DEBUG FALLBACK: no exact template? duplicate ANY template
            // with a matching mask+biome, ignoring tags/floor. Ensures every
            // cell of the level is visible and playable while the catalog
            // is small. Remove this block once unassigned reaches 0 naturally.
            if (_scell.tpl == noone) {
                var _any = scr_tpl_pool(
                    (_sy < GROUND_LINE) ? _surface_biome : _cave_biome,
                    { l: _scell.l, r: _scell.r, u: _scell.u, d: _scell.d },
                    [], -1, -1, 99);
                if (array_length(_any) > 0) {
                    _scell.tpl = _any[irandom(array_length(_any) - 1)];
                    show_debug_message("FALLBACK: cell (" + string(_sx) + "," + string(_sy) +
                        ") mask '" + scr_gen_mask_string(
                        { l: _scell.l, r: _scell.r, u: _scell.u, d: _scell.d }) +
                        "' filled with duplicate of '" + _scell.tpl.name + "'");
                }
            }

            if (_scell.tpl == noone) { _missing++; continue; }

            scr_tpl_stamp(_scell.tpl, _sx, _sy);
            _rooms++;

            for (var _m = 0; _m < array_length(_scell.tpl.markers); _m++) {
                var _mk = _scell.tpl.markers[_m];
                var _wx = _sx * CHUNK_W_PX + _mk.tx * TILE_SIZE;
                var _wy = _sy * CHUNK_H_PY + _mk.ty * TILE_SIZE;
                if (_mk.type == "entrance") {
                    // An entrance marker on a duplicated filler chunk would
                    // spawn extra players — skip markers on fallback cells
                    continue;
                }
                switch (_mk.type) {
                    case "enemy":
                        scr_gen_spawn_clear(_wx + 16, _wy + 16, scr_gen_pick_enemy());
                        break;
                    // case "loot": scr_gen_spawn_clear(_wx + 16, _wy + 16, obj_loot);      break;
                    // case "exit": scr_gen_spawn_clear(_wx + 16, _wy + 16, obj_exit_door);  break;
                }
            }
        }
    }

    // --- 8. SUMMARY ---
    global.gen_dips = _dips;
    show_debug_message("=== LEVEL GENERATED ===");
    show_debug_message("biome: " + _surface_biome + " | seed: " + string(_seed) +
                       " | rooms stamped: " + string(_rooms) +
                       " | unassigned: " + string(_missing) +
                       " | underground sections: " + string(_dips));
    if (_missing > 0) {
        show_debug_message("Unassigned cells = masks with no template. Each 'NO TEMPLATE' line" +
                           " above names one template to paint in rm_workshop, then re-export (F4).");
    }

    return _rooms;
}