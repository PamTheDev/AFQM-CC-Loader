function fair_stick()
{
    var run = true;
    var prevPhase = attack_phase;
    var prevFrame = attack_frame;
    
    if (argument_count > 0)
    {
        anim_sprite = spr_stick_fair;
        var _phase = argument[0];
        
        if (_phase == UnknownEnum.Value_m1)
        {
            prevPhase = -1;
            attack_phase = 0;
            landing_lag = 10;
        }
        else if (_phase == UnknownEnum.Value_m3)
        {
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
                    break;
                
                case 2:
                    attack_stop(UnknownEnum.Value_9);
                    run = false;
                    break;
            }
        }
    }
    
    friction_gravity(air_friction, grav, max_fall_speed);
    fastfall_try();
    aerial_drift();
    
    if (run && cancel_ground_check())
        run = false;
    
    landing_lag = attack_connected() ? 2 : 10;
    
    while (run && (prevPhase != attack_phase || prevFrame != attack_frame))
    {
        if (prevPhase != attack_phase)
        {
            switch (attack_phase)
            {
                case 0:
                    attack_frame = 3;
                    break;
                
                case 1:
                    attack_frame = 11;
                    break;
                
                case 2:
                    attack_frame = 9;
                    break;
            }
        }
        
        prevPhase = attack_phase;
        prevFrame = attack_frame;
        
        switch (attack_phase)
        {
            case 0:
                switch (attack_frame)
                {
                    case 3:
                        anim_frame = 0;
                        break;
                    
                    case 1:
                        anim_frame = 1;
                        game_sound_play(281);
                        break;
                }
                
                break;
            
            case 1:
                switch (attack_frame)
                {
                    case 11:
                        anim_frame = 2;
                        var hitbox1 = hitbox_create_melee(25, -2, 0.94, 0.82, 3.6, 6, 0, 4, 66, 3, UnknownEnum.Value_m2, 0, UnknownEnum.Value_10);
                        hitbox1.hit_vfx_style = UnknownEnum.Value_5;
                        hitbox1.hit_sfx = 19;
                        break;
                    
                    case 9:
                        anim_frame = 3;
                        var hitbox1 = hitbox_create_melee(41, 18, 0.9, 1, 10, 6, 0.8, 6, 0, 3, UnknownEnum.Value_m2, 0, UnknownEnum.Value_10);
                        hitbox1.hit_vfx_style = UnknownEnum.Value_5;
                        hitbox1.hit_sfx = 19;
                        break;
                    
                    case 6:
                        anim_frame = 4;
                        var hitbox1 = hitbox_create_melee(25, -2, 0.94, 0.82, 3.6, 6, 0, 4, 66, 3, UnknownEnum.Value_m2, 0, UnknownEnum.Value_10);
                        hitbox1.hit_vfx_style = UnknownEnum.Value_4;
                        hitbox1.hit_sfx = 19;
                        break;
                }
                
                if (attack_connected())
                {
                    if (cancel_jump_check())
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
            
            case 2:
                switch (attack_frame)
                {
                    case 9:
                        anim_frame = 5;
                        break;
                    
                    case 7:
                        anim_frame = 6;
                        break;
                    
                    case 5:
                        anim_frame = 7;
                        break;
                    
                    case 3:
                        anim_frame = 8;
                        break;
                    
                    case 2:
                        anim_frame = 9;
                        break;
                }
                
                if (attack_connected())
                {
                    if (cancel_jump_check())
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
    
    move_hit_platforms();
}

enum UnknownEnum
{
    Value_m3 = -3,
    Value_m2,
    Value_m1,
    Value_4 = 4,
    Value_5,
    Value_9 = 9,
    Value_10
}
