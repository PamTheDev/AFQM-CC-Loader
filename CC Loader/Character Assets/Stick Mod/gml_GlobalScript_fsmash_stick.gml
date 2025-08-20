function fsmash_stick()
{
    var run = true;
    var prevPhase = attack_phase;
    var prevFrame = attack_frame;
    
    if (argument_count > 0)
    {
        anim_sprite = spr_stick_fsmash;
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
                    attack_frame = 9;
                    break;
                
                case 1:
                    attack_frame = 90;
                    break;
                
                case 2:
                    attack_frame = 26;
                    break;
                
                case 3:
                    attack_frame = 12;
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
                        anim_frame = 1;
                        game_sound_play(34);
                        break;
                    
                    case 5:
                        anim_frame = 1;
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
                    case 90:
                        anim_frame = 1;
                        break;
                }
                
                break;
            
            case 2:
                switch (attack_frame)
                {
                    case 26:
                        anim_frame = 2;
                        game_sound_play(204);
                        break;
                    
                    case 19:
                        anim_frame = 3;
                        break;
                    
                    case 17:
                        anim_frame = 4;
                        var _damage = calculate_smash_damage(13);
                        var hitbox1 = hitbox_create_melee(31, 12, 1.25, 0.63, _damage, 6, 0.8, 9, 62, 3, UnknownEnum.Value_m2, 0);
                        hitbox1.hit_vfx_style = UnknownEnum.Value_2;
                        hitbox1.hit_sfx = 19;
                        break;
                    
                    case 14:
                        anim_frame = 5;
                        break;
                }
                
                break;
            
            case 3:
                switch (attack_frame)
                {
                    case 12:
                        anim_frame = 6;
                        break;
                    
                    case 10:
                        anim_frame = 7;
                        break;
                    
                    case 8:
                        anim_frame = 8;
                        break;
                    
                    case 6:
                        anim_frame = 9;
                        break;
                    
                    case 2:
                        anim_frame = 10;
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
    
    move_grounded();
}

enum UnknownEnum
{
    Value_m3 = -3,
    Value_m2,
    Value_m1,
    Value_0,
    Value_1,
    Value_2,
    Value_5 = 5
}
