/// obj_explosion — play the blast animation once, then expire
image_speed = 3 * scr_dt();   // user-tuned 3x authored pace, dt-corrected
life -= scr_dt();
if (life <= 0) {
    instance_destroy();
}
