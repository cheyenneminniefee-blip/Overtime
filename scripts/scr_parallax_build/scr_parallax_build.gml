/// scr_parallax_build — cache this room's parallax layers from bg_sprites
function scr_parallax_build() {
    layers = [];

    for (var i = 0; i < array_length(bg_sprites); i++) {
        var _spr = bg_sprites[i];
        if (_spr < 0) continue;   // skip deliberately unset slots
        array_push(layers, {
            spr : _spr,
            fac : 0,
            vfac: 0,
            yoff: 0,
            w   : sprite_get_width(_spr),
            h   : sprite_get_height(_spr)
        });
    }

    // If there are more layers than parallax_factors covers, keep halving
    // the last factor for each extra layer back
    while (array_length(parallax_factors) < array_length(layers)) {
        array_push(parallax_factors, parallax_factors[array_length(parallax_factors) - 1] * 0.5);
    }

    // layers[] runs closest -> furthest, so layer 1 takes the fastest factor
    var _v_exact = array_length(vert_factors) == array_length(layers);

    for (var i = 0; i < array_length(layers); i++) {
        layers[i].fac  = parallax_factors[i];
        layers[i].vfac = _v_exact ? vert_factors[i] : parallax_factors[i] * vert_factor_mult;
    }

    _built = true;

    if (array_length(layers) == 0) {
        show_debug_message("WARNING: obj_parallax_bg has no valid sprites in bg_sprites");
    } else {
        show_debug_message("obj_parallax_bg: built " + string(array_length(layers)) + " layer(s)");
    }
}