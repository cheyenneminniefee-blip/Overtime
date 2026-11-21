// --- PLAY ONCE, THEN DESTROY ---
// Repo convention: authored-fps playback via manual advance (image_speed = 0,
// so the built-in animation can never wrap image_index past the end and hide
// the termination condition from this check).
image_index += sprite_get_speed(sprite_index) / game_get_speed(gamespeed_fps);
if (image_index >= image_number - 1) {
    instance_destroy();
}
