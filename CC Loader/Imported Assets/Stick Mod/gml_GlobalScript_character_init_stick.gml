function character_init_stick()
{
    if (!object_is(object_index, 165))
        crash("Trying to run a character init script on an instance that is not an obj_player!\n", "This may be caused by putting parentheses after a script name in Character Data.\n");
    
    var _set_properties = (argument_count > 0) ? argument[0] : true;
    var _set_states = (argument_count > 1) ? argument[1] : true;
    var _set_attacks = (argument_count > 2) ? argument[2] : true;
    var _set_sprites = (argument_count > 3) ? argument[3] : true;
    
    if (_set_properties)
    {
        collision_box = 661;
        hurtbox_sprite = 661;
        hurtbox_crouch_sprite = 661;
        grav = 0.5;
        hitstun_grav = 0.5;
        max_fall_speed = 8;
        fastfall_speed = 10;
        jumpsquat_time = 4;
        jump_speed = 11;
        jump_horizontal_accel = 3;
        shorthop_speed = 6.5;
        double_jump_speed = 8;
        double_jump_horizontal_accel = 2;
        max_double_jumps = 1;
        land_time = 4;
        air_accel = 0.35;
        max_air_speed = 5.25;
        max_air_speed_dash = 6.75;
        air_friction = 0.04;
        airdash_speed = 6;
        hit_cancel_speed = 9;
        airdodge_speed = 9;
        airdodge_startup = 2;
        airdodge_active = 10;
        airdodge_endlag = 20;
        waveland_speed_boost = 1;
        waveland_time = 8;
        waveland_friction = 0.3;
        ground_friction = 0.75;
        crouch_friction = 1;
        slide_friction = 0.5;
        hard_landing_friction = 0.6;
        jostle_strength = 1;
        walk_speed = 2;
        walk_accel = 0.5;
        walk_turn_time = 6;
        dash_speed = 4;
        dash_time = 15;
        dash_accel = 7;
        run_speed = 4;
        run_accel = 0.8;
        run_turn_time = 10;
        run_turn_accel = 1;
        run_stop_time = 4;
        ledge_jump_vsp = 12;
        ledge_jump_hsp = 2;
        ledge_jump_time = 12;
        ledge_getup_time = 23;
        ledge_getup_finish_x = 40;
        ledge_getup_finish_y = -46;
        ledge_roll_time = 11;
        ledge_attack_time = 12;
        ledge_hang_relative_x = -18;
        ledge_hang_relative_y = 22;
        parry_press_startup = 2;
        parry_press_active = 8;
        parry_press_endlag = 30;
        parry_press_trigger_time = 15;
        parry_press_script = parry_press_knockt;
        can_wall_jump = true;
        wall_jump_startup = 2;
        wall_jump_time = 8;
        wall_jump_hsp = 7;
        wall_jump_vsp = -8;
        max_wall_jumps = 1;
        can_wall_cling = false;
        roll_speed = 8;
        roll_startup = 3;
        roll_active = 14;
        roll_endlag = 19;
        getup_active = 16;
        getup_endlag = 8;
        tech_active = 16;
        tech_endlag = 6;
        techroll_speed = 8;
        techroll_startup = 3;
        techroll_active = 14;
        techroll_endlag = 16;
        helpless_accel = 0.5;
        helpless_max_speed = 3;
        item_hold_x_default = 16;
        item_hold_y_default = -4;
        item_hold_r_default = 0;
        weight_multiplier = 1;
        draw_script = -1;
        callback_add(callback_passive, uspec_knockt_passive, UnknownEnum.Value_0);
        callback_add(callback_passive, burst_passive_knockt, UnknownEnum.Value_0);
        callback_add(callback_passive, knockt_fuel_passive, UnknownEnum.Value_0);
        callback_add(callback_draw_begin, knockt_fuel_draw, UnknownEnum.Value_0);
    }
    
    if (_set_states)
        player_states_init();
    
    if (_set_attacks)
    {
        variable_struct_set(my_attacks, "Jab", jab_stick);
        variable_struct_set(my_attacks, "DashAtk", dash_attack_stick);
        variable_struct_set(my_attacks, "Ftilt", ftilt_stick);
        variable_struct_set(my_attacks, "Utilt", utilt_stick);
        variable_struct_set(my_attacks, "Dtilt", dtilt_stick);
        variable_struct_set(my_attacks, "Fsmash", fsmash_stick);
        variable_struct_set(my_attacks, "Usmash", usmash_stick);
        variable_struct_set(my_attacks, "Dsmash", dsmash_stick);
        variable_struct_set(my_attacks, "Nair", nair_stick);
        variable_struct_set(my_attacks, "Fair", fair_stick);
        variable_struct_set(my_attacks, "Bair", bair_stick);
        variable_struct_set(my_attacks, "Uair", uair_stick);
        variable_struct_set(my_attacks, "Dair", dair_stick);
        variable_struct_set(my_attacks, "Zair", -1);
        variable_struct_set(my_attacks, "Nspec", fspec_stick);
        variable_struct_set(my_attacks, "Fspec", fspec_stick);
        variable_struct_set(my_attacks, "Uspec", uspec_stick);
        variable_struct_set(my_attacks, "Dspec", dspec_stick);
        variable_struct_set(my_attacks, "Grab", -1);
        variable_struct_set(my_attacks, "DashGrab", -1);
        variable_struct_set(my_attacks, "Pummel", -1);
        variable_struct_set(my_attacks, "FThrow", -1);
        variable_struct_set(my_attacks, "BThrow", -1);
        variable_struct_set(my_attacks, "UThrow", -1);
        variable_struct_set(my_attacks, "DThrow", -1);
        variable_struct_set(my_attacks, "GetupAtk", jab_stick);
        variable_struct_set(my_attacks, "LedgeAtk", -1);
        variable_struct_set(my_attacks, "ItemThrow", -1);
        variable_struct_set(my_attacks, "ItemAtk", -1);
        variable_struct_set(my_attacks, "Taunt", -1);
        variable_struct_set(my_attacks, "Final", final_knockt);
    }
    
    if (_set_sprites)
    {
        sprite_scale = 1;
        variable_struct_set(my_sprites, "Entrance", anim_define(spr_stick_idle, spr_stick_idle));
        variable_struct_set(my_sprites, "Idle", spr_stick_idle);
        variable_struct_set(my_sprites, "Crouch", spr_stick_crouch);
        variable_struct_set(my_sprites, "Walk", anim_define(spr_stick_walk, spr_stick_walk));
        variable_struct_set(my_sprites, "Walk_Turn", spr_stick_walk);
        variable_struct_set(my_sprites, "Dash", spr_stick_crouch);
        variable_struct_set(my_sprites, "Run", spr_stick_dash);
        variable_struct_set(my_sprites, "Run_Turn", spr_stick_idle);
        variable_struct_set(my_sprites, "Run_Stop", spr_stick_idle);
        variable_struct_set(my_sprites, "JumpSquat", spr_stick_jump_squat);
        variable_struct_set(my_sprites, "JumpRise", anim_define(spr_stick_idle, spr_stick_idle));
        variable_struct_set(my_sprites, "JumpMid", spr_stick_idle);
        variable_struct_set(my_sprites, "JumpFall", spr_stick_idle);
        variable_struct_set(my_sprites, "Fastfall", spr_stick_fast_fall);
        variable_struct_set(my_sprites, "DJumpRise", anim_define(spr_stick_idle, spr_stick_idle));
        variable_struct_set(my_sprites, "DJumpMid", -1);
        variable_struct_set(my_sprites, "DJumpFall", -1);
        variable_struct_set(my_sprites, "DFastfall", -1);
        variable_struct_set(my_sprites, "Airdodge", -1);
        variable_struct_set(my_sprites, "Airdash", spr_stick_air_dash);
        variable_struct_set(my_sprites, "Waveland", spr_stick_wave_dash);
        variable_struct_set(my_sprites, "Rolling", spr_stick_techroll);
        variable_struct_set(my_sprites, "SDodge", -1);
        variable_struct_set(my_sprites, "Shield", -1);
        variable_struct_set(my_sprites, "ShieldR", -1);
        variable_struct_set(my_sprites, "ShieldB", -1);
        variable_struct_set(my_sprites, "ShieldHigh", -1);
        variable_struct_set(my_sprites, "ShieldMid", -1);
        variable_struct_set(my_sprites, "ShieldLow", -1);
        variable_struct_set(my_sprites, "ShieldHeld", -1);
        variable_struct_set(my_sprites, "ParryS", -1);
        variable_struct_set(my_sprites, "parry_ult_sprite", -1);
        variable_struct_set(my_sprites, "Hitlag", spr_stick_hitlag);
        variable_struct_set(my_sprites, "Hitstun", spr_stick_hitstun);
        variable_struct_set(my_sprites, "Tumble", spr_stick_techroll);
        variable_struct_set(my_sprites, "Helpless", spr_stick_idle);
        variable_struct_set(my_sprites, "Magnet", spr_magnetized_knockt);
        variable_struct_set(my_sprites, "Flinch", spr_stick_flinch);
        variable_struct_set(my_sprites, "Lag", spr_stick_crouch);
        variable_struct_set(my_sprites, "Balloon", spr_balloon_knockt);
        variable_struct_set(my_sprites, "Reeling", spr_stick_reeling);
        variable_struct_set(my_sprites, "Knockdown", anim_define(spr_stick_knockdown, spr_stick_knockeddown));
        variable_struct_set(my_sprites, "Lock", spr_stick_lock);
        variable_struct_set(my_sprites, "Getup", spr_stick_get_up);
        variable_struct_set(my_sprites, "Techroll", spr_stick_techroll);
        variable_struct_set(my_sprites, "Teching", spr_stick_get_up);
        variable_struct_set(my_sprites, "TechingW", spr_stick_idle);
        variable_struct_set(my_sprites, "TechingC", -1);
        variable_struct_set(my_sprites, "Techjump", -1);
        variable_struct_set(my_sprites, "LedgeS", -1);
        variable_struct_set(my_sprites, "Ledge", -1);
        variable_struct_set(my_sprites, "LedgeG", -1);
        variable_struct_set(my_sprites, "LedgeJ", -1);
        variable_struct_set(my_sprites, "LedgeR", -1);
        variable_struct_set(my_sprites, "LedgeA", -1);
        variable_struct_set(my_sprites, "LedgeT", -1);
        variable_struct_set(my_sprites, "LedgeTr", -1);
        variable_struct_set(my_sprites, "WallC", spr_stick_wall_cling);
        variable_struct_set(my_sprites, "WallJ", spr_stick_idle);
        variable_struct_set(my_sprites, "StarKO", -1);
        variable_struct_set(my_sprites, "ScreenKO", -1);
        variable_struct_set(my_sprites, "Grabbing", -1);
        variable_struct_set(my_sprites, "IsGrabbed", -1);
        variable_struct_set(my_sprites, "GrabRel", -1);
    }
}

enum UnknownEnum
{
    Value_0
}
