/// scr_spawn_solid_rect(_px, _py, _w_tiles, _h_tiles)
// One obj_solid_tile covering the tile rectangle whose top-left pixel is
// (_px, _py). Origin-agnostic and instance-independent: object_get_sprite
// reads the sprite from the OBJECT ASSET (the IDE definition), not from a
// live instance — so it works even when the room has zero solids yet.
function scr_spawn_solid_rect(_px, _py, _w_tiles, _h_tiles) {
    var _spr  = object_get_sprite(obj_solid_tile);
    var _inst = instance_create_layer(
        _px + sprite_get_xoffset(_spr) * _w_tiles,
        _py + sprite_get_yoffset(_spr) * _h_tiles,
        layer_get_id("Instances"), obj_solid_tile);
    _inst.image_xscale = _w_tiles;
    _inst.image_yscale = _h_tiles;
    return _inst;
}