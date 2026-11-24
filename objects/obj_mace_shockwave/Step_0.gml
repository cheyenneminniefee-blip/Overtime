// --- PLAY ONCE, THEN DESTROY ---
// Repo convention (see obj_phase_slash_vfx): authored-fps playback via manual
// advance. This sprite is 2 frames at 5 fps = 0.4 s of ground crack; the
// second frame renders for its full hold, THEN the instance dies.
image_index += sprite_get_speed(sprite_index) / game_get_speed(gamespeed_fps);
if (image_index >= image_number) {
    instance_destroy();
}
