function jab_stick()
{
    var run = true;
    var prevPhase = attack_phase;
    var prevFrame = attack_frame;
    
    if (argument_count > 0)
    {
        anim_sprite = spr_stick_jab;
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
                    anim_frame = 3;
                    attack_frame = 6;
                    break;
                
                case 1:
                    attack_frame = 3;
                    break;
                
                case 2:
                    attack_frame = 8;
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
                    case 6:
                        anim_frame = 0;
                        break;
                    
                    case 2:
                        game_sound_play(245);
                        break;
                }
                
                break;
            
            case 1:
                switch (attack_frame)
                {
                    case 3:
                        anim_frame = 4;
                        var hitbox1 = hitbox_create_melee(22, -2, 1.05, 0.83, 2.1, 4, 0, 3, 75, 3, UnknownEnum.Value_m2, 0);
                        hitbox1.hit_sfx = 26;
                        hitbox1.techable = false;
                        hitbox1.custom_hitstun = 15;
                        break;
                }
                
                if (attack_connected())
                {
                    if ((stick_tilted(0) && allow_tilt_attacks()) || (stick_tilted(1) && allow_tilt_attacks()))
                    {
                        run = false;
                        break;
                    }
                }
                
                break;
            
            case 2:
                if (attack_connected())
                {
                    if ((stick_tilted(0) && allow_tilt_attacks()) || (stick_tilted(1) && allow_tilt_attacks()))
                    {
                        run = false;
                        break;
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
    Value_0
}
