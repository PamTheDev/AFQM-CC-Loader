function uair_stick()
{
    var run = true;
    var prevPhase = attack_phase;
    var prevFrame = attack_frame;
    
    if (argument_count > 0)
    {
        anim_sprite = spr_stick_uair;
        var _phase = argument[0];
        
        if (_phase == UnknownEnum.Value_m1)
        {
            prevPhase = -1;
            attack_phase = 0;
            landing_lag = 8;
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
    
    landing_lag = attack_connected() ? 2 : 6;
    
    while (run && (prevPhase != attack_phase || prevFrame != attack_frame))
    {
        if (prevPhase != attack_phase)
        {
            switch (attack_phase)
            {
                case 0:
                    attack_frame = 8;
                    break;
                
                case 1:
                    attack_frame = 7;
                    break;
                
                case 2:
                    attack_frame = 18;
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
                    case 8:
                        anim_frame = 0;
                        break;
                    
                    case 3:
                        anim_frame = 1;
                        game_sound_play(73);
                        break;
                }
                
                break;
            
            case 1:
                switch (attack_frame)
                {
                    case 7:
                        anim_frame = 2;
                        var hitbox1 = hitbox_create_melee(-1, -23, 0.66, 1.22, 4.6, 8, 0.6, 5, 84, 2, UnknownEnum.Value_m2, 0);
                        hitbox1.hit_vfx_style = UnknownEnum.Value_5;
                        hitbox1.hit_sfx = 107;
                        break;
                    
                    case 5:
                        var hitbox1 = hitbox_create_melee(-3, -31, 0.47, 0.95, 4.4, 6, 0.2, 6, 84, 5, UnknownEnum.Value_m2, 0);
                        hitbox1.hit_vfx_style = UnknownEnum.Value_5;
                        hitbox1.hit_sfx = 107;
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
                    case 18:
                        anim_frame = 3;
                        break;
                    
                    case 10:
                        anim_frame = 4;
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
    Value_5 = 5,
    Value_9 = 9
}
