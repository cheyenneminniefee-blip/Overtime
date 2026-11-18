/// obj_player_death — corpse draw
// spr_player_death has a centered origin, and the header/body layers are
// baked into the sprite's own frames — no normal map to apply.
draw_sprite_ext(sprite_index, image_index, x, y, facing_dir, 1, 0, c_white, 1);
