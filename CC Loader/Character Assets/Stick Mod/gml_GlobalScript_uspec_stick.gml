function uspec_stick()
{
    var run = true;
    var prevPhase = attack_phase;
    var prevFrame = attack_frame;
    
    if (argument_count > 0)
    {
        anim_sprite = spr_stick_uspec;
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
                    attack_stop(UnknownEnum.Value_9);
                    break;
            }
        }
    }
    
    if (on_ground())
    {
        friction_gravity(ground_friction, grav, max_fall_speed);
    }
    else
    {
        friction_gravity(air_friction / 2, 0.2, max_fall_speed);
        aerial_drift();
    }
    
    while (run && (prevPhase != attack_phase || prevFrame != attack_frame))
    {
        if (prevPhase != attack_phase)
        {
            switch (attack_phase)
            {
                case 0:
                    attack_frame = 30;
                    break;
                
                case 1:
                    attack_frame = 88;
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
                    case 30:
                        anim_frame = 0;
                        game_sound_play(151);
                        break;
                    
                    case 28:
                        anim_frame = 1;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 27:
                        anim_frame = 2;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 22:
                        anim_frame = 3;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 17:
                        anim_frame = 4;
                        game_sound_play(151);
                        break;
                    
                    case 13:
                        anim_frame = 5;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 10:
                        anim_frame = 6;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 7:
                        anim_frame = 7;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 5:
                        anim_frame = 1;
                        speed_set(hsp, -5, false, false);
                        break;
                }
                
                break;
            
            case 1:
                switch (attack_frame)
                {
                    case 88:
                        anim_frame = 2;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 82:
                        anim_frame = 3;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 75:
                        anim_frame = 4;
                        game_sound_play(151);
                        break;
                    
                    case 70:
                        anim_frame = 5;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 67:
                        anim_frame = 6;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 64:
                        anim_frame = 7;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 59:
                        anim_frame = 8;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 54:
                        anim_frame = 1;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 50:
                        anim_frame = 2;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 43:
                        anim_frame = 3;
                        game_sound_play(151);
                        break;
                    
                    case 36:
                        anim_frame = 4;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 31:
                        anim_frame = 5;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 26:
                        anim_frame = 6;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 20:
                        anim_frame = 7;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 13:
                        anim_frame = 1;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 5:
                        anim_frame = 2;
                        speed_set(hsp, -5, false, false);
                        break;
                    
                    case 2:
                        anim_frame = 3;
                        speed_set(hsp, -5, false, false);
                        break;
                }
                
                if (on_ground)
                {
                    attack_stop(UnknownEnum.Value_9);
                    game_sound_play(102);
                    run = false;
                }
                else
                {
                    attack_stop(UnknownEnum.Value_9);
                    game_sound_play(102);
                    run = false;
                }
                
                break;
        }
    }
    
    move();
}

enum UnknownEnum
{
    Value_m1 = -1,
    Value_9 = 9
}
