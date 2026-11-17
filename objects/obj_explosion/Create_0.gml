/// obj_explosion — grenade blast visual (PRD 5.6: 72 px blast radius)
// Plays spr_explosion once at its authored playback speed, sized to the blast
// radius, then frees itself (plain-lifetime hazard visual, PRD 11.3).
depth = -50;                 // Draw over enemies and projectiles
image_speed = 0;
image_xscale = 2.25;         // 64 px sprite * 2.25 = 144 px wide = the 72 px blast radius
image_yscale = 2.25;

// Drive the animation from the sprite's authored fps, not the game fps
image_speed = sprite_get_speed(spr_explosion) / game_get_speed(gamespeed_fps);

// Lifetime = one full pass of the animation
life = ceil(sprite_get_number(spr_explosion) * game_get_speed(gamespeed_fps) / sprite_get_speed(spr_explosion));
