/// obj_player_death — advance the death animation once, then hold the last frame
if (image_index < image_number - 1) {
    image_index += sprite_get_speed(spr_player_death) / game_get_speed(gamespeed_fps);
    if (image_index >= image_number - 1) {
        image_index = image_number - 1;
    }
}
