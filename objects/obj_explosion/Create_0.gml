/// obj_explosion — grenade blast visual (PRD 5.6: 72 px blast radius)
// Plays spr_explosion once at its authored playback speed, sized to the blast
// radius, then frees itself (plain-lifetime hazard visual, PRD 11.3).
depth = -50;                 // Draw over enemies and projectiles
image_speed = 3;
image_xscale = 2.25;         // 64 px sprite * 2.25 = 144 px wide = the 72 px blast radius
image_yscale = 2.25;



// Lifetime = one full pass of the animation
life = 10;
