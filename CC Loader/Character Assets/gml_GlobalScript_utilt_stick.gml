function utilt_stick()
{
    var run = true;
    var prevPhase = attack_phase;
    var prevFrame = attack_frame;
    
    if (argument_count > 0)
    {
        anim_sprite = spr_stick_utilt;
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
                    attack_frame = 4;
                    break;
                
                case 1:
                    attack_frame = 4;
                    break;
                
                case 2:
                    attack_frame = 20;
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
                    case 4:
                        anim_frame = 0;
                        break;
                    
                    case 2:
                        game_sound_play(212);
                        break;
                }
                
                break;
            
            case 1:
                switch (attack_frame)
                {
                    case 4:
                        anim_frame = 1;
                        var hitbox1 = hitbox_create_melee(0, 6, 0.55, 0.56, 4.1, 5, 0.6, 6, 88, 2, UnknownEnum.Value_m2, 0);
                        hitbox1.hit_vfx_style = UnknownEnum.Value_11;
                        hitbox1.hit_sfx = 29;
                        var hitbox2 = hitbox_create_melee(-5, 15, 0.29, 0.3, 4.1, 5, 0.6, 6, 88, 2, UnknownEnum.Value_m2, 0);
                        hitbox2.hit_vfx_style = UnknownEnum.Value_11;
                        hitbox2.hit_sfx = 29;
                        game_sound_play(258);
                        break;
                    
                    case 2:
                        anim_frame = 2;
                        var hitbox1 = hitbox_create_melee(-7, -5, 0.81, 0.84, 4.1, 5, 0.6, 6, 88, 2, UnknownEnum.Value_m2, 0);
                        hitbox1.hit_vfx_style = UnknownEnum.Value_12;
                        hitbox1.hit_sfx = 29;
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
            
            case 2:
                switch (attack_frame)
                {
                    case 20:
                        anim_frame = 3;
                        var hitbox1 = hitbox_create_melee(-6, -28, 0.36, 0.54, 3.5, 4, 0.4, 4, 108, 2, UnknownEnum.Value_m2, 0);
                        hitbox1.hit_vfx_style = UnknownEnum.Value_11;
                        hitbox1.hit_sfx = 29;
                        var hitbox2 = hitbox_create_melee(0, -6, 0.36, 0.54, 3.5, 4, 0.4, 4, 108, 2, UnknownEnum.Value_m2, 0);
                        hitbox2.hit_vfx_style = UnknownEnum.Value_11;
                        hitbox2.hit_sfx = 29;
                        break;
                    
                    case 15:
                        anim_frame = 4;
                        break;
                    
                    case 9:
                        anim_frame = 5;
                        break;
                    
                    case 4:
                        anim_frame = 6;
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
    Value_11 = 11,
    Value_12
}
