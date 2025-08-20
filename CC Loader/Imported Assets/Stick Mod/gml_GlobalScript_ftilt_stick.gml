function ftilt_stick()
{
    var run = true;
    var prevPhase = attack_phase;
    var prevFrame = attack_frame;
    
    if (argument_count > 0)
    {
        anim_sprite = spr_stick_ftilt;
        var _phase = argument[0];
        
        if (_phase == UnknownEnum.Value_m1)
        {
            prevPhase = -1;
            attack_phase = 0;
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
                    attack_stop(UnknownEnum.Value_0);
                    run = false;
                    break;
            }
        }
    }
    
    friction_gravity(ground_friction, grav, max_fall_speed);
    
    if (run && cancel_air_check())
        run = false;
    
    while (run && (prevPhase != attack_phase || prevFrame != attack_frame))
    {
        if (prevPhase != attack_phase)
        {
            switch (attack_phase)
            {
                case 0:
                    attack_frame = 9;
                    break;
                
                case 1:
                    attack_frame = 17;
                    break;
                
                case 2:
                    attack_frame = 23;
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
                    case 9:
                        anim_frame = 0;
                        break;
                    
                    case 2:
                        game_sound_play(223);
                        break;
                }
                
                break;
            
            case 1:
                switch (attack_frame)
                {
                    case 17:
                        anim_frame = 1;
                        var hitbox1 = hitbox_create_melee(28, -4, 1, 0.41, 1.5, 3, 0.1, 4, 0, 4, UnknownEnum.Value_m2, 0, UnknownEnum.Value_10);
                        hitbox1.hit_vfx_style = UnknownEnum.Value_4;
                        hitbox1.hit_sfx = 241;
                        break;
                    
                    case 11:
                        game_sound_play(159);
                        break;
                    
                    case 4:
                        anim_frame = 2;
                        var hitbox1 = hitbox_create_melee(29, -4, 1, 0.41, 6.4, 7, 0.7, 7, 0, 4, UnknownEnum.Value_m2, 1, UnknownEnum.Value_10);
                        hitbox1.hit_vfx_style = UnknownEnum.Value_4;
                        hitbox1.hit_sfx = 9;
                        break;
                }
                
                break;
            
            case 2:
                switch (attack_frame)
                {
                    case 23:
                        anim_frame = 3;
                        break;
                    
                    case 17:
                        anim_frame = 4;
                        break;
                    
                    case 9:
                        anim_frame = 5;
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
    
    move_grounded();
}

enum UnknownEnum
{
    Value_m2 = -2,
    Value_m1,
    Value_0,
    Value_4 = 4,
    Value_10 = 10
}
