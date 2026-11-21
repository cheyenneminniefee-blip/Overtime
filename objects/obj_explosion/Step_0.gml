/// obj_explosion — play the blast animation once, then expire
life -= 1;
if (life <= 0) {
    instance_destroy();
}
