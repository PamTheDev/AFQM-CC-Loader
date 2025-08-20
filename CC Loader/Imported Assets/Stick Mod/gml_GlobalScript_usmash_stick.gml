function usmash_stick()
{
    var run = true;
    var prevPhase = attack_phase;
    var prevFrame = attack_frame;
    
    if (argument_count > 0)
    {
        anim_sprite = spr_stick_usmash;
        var _phase = argument[0];
        
        if (_phase == UnknownEnum.Value_m1)
        {
            prevPhase = -1;
            attack_phase = 0;
            charge = 0;
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
                    if ((!input_held(UnknownEnum.Value_5) && !input_held(UnknownEnum.Value_0) && !input_held(UnknownEnum.Value_1)) || charge >= 90)
                        attack_phase = 2;
                    else
                        attack_phase++;
                    
                    break;
                
                case 1:
                    attack_phase++;
                    break;
                
                case 2:
                    attack_phase++;
                    break;
                
                case 3:
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
                    attack_frame = 89;
                    break;
                
                case 2:
                    attack_frame = 6;
                    break;
                
                case 3:
                    attack_frame = 31;
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
                        anim_frame = 1;
                        game_sound_play(168);
                        break;
                }
                
                break;
            
            case 1:
                charge++;
                
                if ((!input_held(UnknownEnum.Value_5) && !input_held(UnknownEnum.Value_0) && !input_held(UnknownEnum.Value_1)) || charge >= 90)
                {
                    attack_phase = 2;
                    break;
                }
                else if ((charge % 10) == 0)
                {
                    vfx_create(691, 1, 0, 8, x + prng_number(0, 20, -20), y + prng_number(1, 20, -20), 1, prng_number(0, 360));
                }
                
                switch (attack_frame)
                {
                    case 89:
                        anim_frame = 1;
                        break;
                }
                
                break;
            
            case 2:
                switch (attack_frame)
                {
                    case 6:
                        anim_frame = 2;
                        game_sound_play(175);
                        break;
                    
                    case 4:
                        anim_frame = 3;
                        break;
                    
                    case 3:
                        anim_frame = 4;
                        var _damage = calculate_smash_damage(15);
                        var hitbox1 = hitbox_create_melee(18, -20, 0.54, 0.83, _damage, 5, 0.8, 9, 69, 3, UnknownEnum.Value_m2, 0);
                        hitbox1.hit_sfx = 144;
                        var hitbox2 = hitbox_create_melee(5, 4, 0.34, 0.47, _damage, 5, 0.8, 9, 69, 3, UnknownEnum.Value_m2, 0);
                        hitbox2.hit_sfx = 144;
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
            
            case 3:
                switch (attack_frame)
                {
                    case 31:
                        anim_frame = 4;
                        break;
                    
                    case 17:
                        anim_frame = 5;
                        break;
                    
                    case 6:
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
    Value_m3 = -3,
    Value_m2,
    Value_m1,
    Value_0,
    Value_1,
    Value_5 = 5
}
