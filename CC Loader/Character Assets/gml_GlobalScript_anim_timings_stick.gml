function anim_timings_stick()
{
    ds_map_set(global.sprite_timings, spr_stick_idle, [2]);
    ds_map_set(global.sprite_timings, spr_stick_crouch, [2]);
    ds_map_set(global.sprite_timings, spr_css_idle_stick, [2]);
    ds_map_set(global.sprite_timings, spr_stick_jump_squat, [2]);
    ds_map_set(global.sprite_timings, spr_stick_get_up, [3, 3, 2, 2, 2, 3, 4]);
    ds_map_set(global.sprite_timings, spr_stick_jab, [3, 3, 2, 2, 2, 3, 4]);
    ds_map_set(global.sprite_timings, spr_stick_ftilt, [6, 6, 6, 6, 6, 9, 9]);
    ds_map_set(global.sprite_timings, spr_stick_lock, [4, 4, 3, 5]);
    ds_map_set(global.sprite_timings, spr_stick_fast_fall, [60]);
    ds_map_set(global.sprite_timings, spr_stick_wave_dash, [4, 4, 4, 40]);
    ds_map_set(global.sprite_timings, spr_stick_air_dash, [4, 4, 4, 40]);
    ds_map_set(global.sprite_timings, spr_stick_walk, [3, 3, 3, 3]);
    ds_map_set(global.sprite_timings, spr_stick_hitlag, [60]);
    ds_map_set(global.sprite_timings, spr_stick_dash, [3, 2, 2, 4, 2, 2, 3]);
    ds_map_set(global.sprite_timings, spr_stick_techroll, [3, 2, 2, 2, 2, 2, 2, 2, 1, 2, 3, 4, 39]);
    ds_map_set(global.sprite_timings, spr_stick_reeling, [4, 4, 4, 4, 4, 4]);
}
