/// obj_enemy_death — advance the death animation once, then hold the last frame
if (image_index < image_number - 1) {
    image_index += sprite_get_speed(spr_enemy_death) / game_get_speed(gamespeed_fps) * scr_dt();
    if (image_index >= image_number - 1) {
        image_index = image_number - 1;
    }
}

// Settle the killing-blow squash (same lerp as the living enemies)
draw_xscale = scr_dt_lerp(draw_xscale, 1, 0.1);
draw_yscale = scr_dt_lerp(draw_yscale, 1, 0.1);
