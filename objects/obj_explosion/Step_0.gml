/// obj_explosion — grow to the full 72 px blast radius, then expire
// 64 px sprite * 2.25 = 144 px wide = the 72 px blast radius (PRD 5.6).
// 64 * 0.0625 = 4 px per frame of re-offset keeps the growth centered.
image_xscale += 0.0625;
image_yscale += 0.0625;
x -= 2;
y -= 2;

life -= 1;
if (life <= 0) {
    instance_destroy();
}
