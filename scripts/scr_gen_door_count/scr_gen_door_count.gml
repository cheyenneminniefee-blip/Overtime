/// scr_gen_door_count(_cell)
function scr_gen_door_count(_cell) {
    return (_cell.l ? 1 : 0) + (_cell.r ? 1 : 0) + (_cell.u ? 1 : 0) + (_cell.d ? 1 : 0);
}