/// obj_explosion — grow to the full 72 px blast radius, then expire
// 64 px sprite * 2.25 = 144 px wide = the 72 px blast radius (PRD 5.6).
// The centered sprite origin keeps the growth centered on the blast point.
image_xscale += 0.0625;
image_yscale += 0.0625;

life -= 1;
if (life <= 0) {
    instance_destroy();
}
