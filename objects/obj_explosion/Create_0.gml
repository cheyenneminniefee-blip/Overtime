/// obj_explosion — draw-only grenade blast visual (PRD 5.6: 72 px blast radius)
// Non-animated hazard visual with a plain lifetime (PRD 11.3). The sprite is
// a single 64 x 64 frame with a top-left origin, so the instance is spawned
// offset and re-offset while growing to stay centered on the blast point.
depth = -50;                 // Draw over enemies and projectiles
life = 12;                   // 0.2 s at 60 fps
image_speed = 0;
image_xscale = 1.5;
image_yscale = 1.5;
