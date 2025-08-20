function fspec_stick()
{
    var run = true;
    var prevPhase = attack_phase;
    var prevFrame = attack_frame;
    
    if (argument_count > 0)
    {
        anim_sprite = spr_stick_fspec;
        var _phase = argument[0];
        
        if (_phase == UnknownEnum.Value_m1)
        {
            prevPhase = -1;
            landing_lag = 12;
            callback_add(callback_draw_begin, rend_fspec_chokeslam_draw);
            custom_attack_struct.chokeslam_anchor_x = undefined;
            custom_attack_struct.chokeslam_anchor_y = undefined;
            vfx_create(691, 1, 0, 8, x + (-16 * facing), y + 4, 1, prng_number(0, 360));
            
            if (on_ground())
                attack_phase = 6;
            else
                attack_phase = 6;
        }
        else if (_phase == UnknownEnum.Value_m3)
        {
            var _target = argument[1];
            var _hitbox = argument[2];
            var _hurtbox = argument[3];
            
            if (!object_is(_target.object_index, 165))
                exit;
            
            switch (_hurtbox.inv_type)
            {
                case UnknownEnum.Value_1:
                case UnknownEnum.Value_9:
                case UnknownEnum.Value_10:
                    break;
                
                case UnknownEnum.Value_0:
                case UnknownEnum.Value_6:
                case UnknownEnum.Value_7:
                case UnknownEnum.Value_8:
                case UnknownEnum.Value_4:
                case UnknownEnum.Value_5:
                case UnknownEnum.Value_3:
                case UnknownEnum.Value_2:
                default:
                    command_grab(_target, 47, -16);
                    attack_phase = 3;
                    
                    with (_target)
                        player_move_to_back();
                    
                    speed_set(4 * facing, -12, false, false);
                    _target.facing = -facing;
                    hitbox_destroy(_hitbox);
                    break;
            }
        }
        else
        {
            prevPhase = -1;
            attack_phase = _phase;
        }
    }
    else
    {
        attack_frame = max(--attack_frame, 0);
        
        if (attack_frame == 0)
        {
            prevPhase = -1;
            
            switch (attack_phase)
            {
                case 0:
                    attack_phase++;
                    break;
                
                case 1:
                    attack_phase++;
                    
                    if (on_ground())
                        friction_gravity(ground_friction);
                    else
                        friction_gravity(air_friction, grav, max_fall_speed);
                    
                    break;
                
                case 2:
                    if (on_ground())
                        attack_stop(UnknownEnum.Value_0);
                    else
                        attack_stop(UnknownEnum.Value_9);
                    
                    break;
                
                case 3:
                    attack_phase++;
                    var _s = custom_attack_struct;
                    
                    if (is_undefined(_s.chokeslam_anchor_x) || is_undefined(_s.chokeslam_anchor_y))
                        speed_set(0, 17, true, false);
                    
                    break;
                
                case 4:
                    break;
                
                case 5:
                    attack_stop(UnknownEnum.Value_0);
                    break;
                
                case 6:
                    attack_phase++;
                    break;
                
                case 7:
                    attack_phase++;
                    speed_set(hsp, -1, false, false);
                    friction_gravity(slide_friction, grav, max_fall_speed);
                    break;
                
                case 8:
                    attack_stop();
                    break;
            }
        }
    }
    
    if (!on_ground())
        friction_gravity(air_friction, grav, max_fall_speed);
    else
        friction_gravity(slide_friction, grav, max_fall_speed);
    
    while (run && (prevPhase != attack_phase || prevFrame != attack_frame))
    {
        if (prevPhase != attack_phase)
        {
            switch (attack_phase)
            {
                case 6:
                    attack_frame = 6;
                    break;
                
                case 7:
                    attack_frame = 2;
                    break;
                
                case 8:
                    attack_frame = 25;
                    break;
            }
        }
        
        prevPhase = attack_phase;
        prevFrame = attack_frame;
        
        switch (attack_phase)
        {
            case 6:
                switch (attack_frame)
                {
                    case 5:
                        anim_frame = 1;
                        break;
                    
                    case 3:
                        anim_frame = 2;
                        break;
                }
                
                break;
            
            case 7:
                switch (attack_frame)
                {
                    case 2:
                        anim_frame = 3;
                        speed_set(facing * 2, -1, false, false);
                        break;
                    
                    case 1:
                        game_sound_play(14);
                        break;
                }
                
                break;
            
            case 8:
                switch (attack_frame)
                {
                    case 25:
                        anim_frame = 4;
                        break;
                    
                    case 24:
                        anim_frame = 5;
                        break;
                    
                    case 22:
                        anim_frame = 6;
                        break;
                    
                    case 20:
                        game_sound_play(103);
                        break;
                    
                    case 19:
                        anim_frame = 7;
                        speed_set(facing * 5, -5, false, false);
                        break;
                    
                    case 18:
                        anim_frame = 1;
                        var hitbox1 = hitbox_create_melee(47, -12, 1, 0.6, 6.8, 4, 0.5, 6, 0, 2, UnknownEnum.Value_m2, 0, UnknownEnum.Value_10);
                        hitbox1.hit_vfx_style = UnknownEnum.Value_4;
                        hitbox1.hit_sfx = 251;
                        break;
                    
                    case 17:
                        anim_frame = 2;
                        var hitbox1 = hitbox_create_melee(23, 6, 1.4, 0.6, 6.8, 4, 0.5, 6, 0, 3, UnknownEnum.Value_m2, 0, UnknownEnum.Value_10);
                        hitbox1.hit_vfx_style = UnknownEnum.Value_4;
                        hitbox1.hit_sfx = 251;
                        break;
                    
                    case 15:
                        anim_frame = 3;
                        break;
                    
                    case 13:
                        anim_frame = 4;
                        break;
                }
                
                if (attack_connected())
                {
                    if (check_jump())
                    {
                        run = false;
                        exit;
                    }
                    
                    if (check_hit_cancel())
                    {
                        run = false;
                        exit;
                    }
                }
                
                break;
        }
    }
    
    move();
}

enum UnknownEnum
{
    Value_m3 = -3,
    Value_m2,
    Value_m1,
    Value_0,
    Value_1,
    Value_2,
    Value_3,
    Value_4,
    Value_5,
    Value_6,
    Value_7,
    Value_8,
    Value_9,
    Value_10
}
