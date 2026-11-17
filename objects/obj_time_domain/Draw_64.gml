/// obj_time_domain — Draw GUI: the world freeze tint (PRD 5.2 / 12.3)
// A light icy wash over everything while FROZEN — distinct from the white
// damage flash, and count/timing carried by the frozen sprites themselves.
if (global.time_frozen) {
    draw_set_alpha(0.10);
    draw_set_color(FREEZE_TINT);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
