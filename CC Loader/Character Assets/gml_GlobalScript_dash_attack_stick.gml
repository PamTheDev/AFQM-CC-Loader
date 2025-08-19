function dash_attack_stick()
{
    var run = true;
    var _phase = (argument_count > 0) ? argument[0] : attack_phase;
    attack_frame = max(--attack_frame, 0);
    
    if (run && cancel_air_check())
        run = false;
    
    if (run)
    {
        switch (_phase)
        {
            case UnknownEnum.Value_m1:
                anim_sprite = spr_stick_dash_attack;
                anim_speed = 0;
                anim_frame = 0;
                attack_frame = 11;
                exit;
            
            case 0:
                friction_gravity(ground_friction, grav, max_fall_speed);
                
                if (attack_frame == 9)
                    anim_frame = 1;
                
                if (attack_frame == 5)
                    anim_frame = 2;
                
                if (attack_frame == 2)
                    anim_frame = 3;
                
                if (attack_frame == 0)
                {
                    speed_set(6 * facing, 0, false, false);
                    anim_frame = 4;
                    attack_phase++;
                    attack_frame = 10;
                    var _hitbox = hitbox_create_melee(12, 6, 1.1, 0.5, 4, 5, 1.1, 10, 65, 2, UnknownEnum.Value_m1, 0);
                    _hitbox.hit_vfx_style = UnknownEnum.Value_2;
                    _hitbox.hit_sfx = 143;
                    _hitbox.knockback_state = UnknownEnum.Value_27;
                }
                
                break;
            
            case 1:
                if (attack_frame == 8)
                {
                    anim_frame = 5;
                    var _hitbox = hitbox_create_melee(12, 6, 1.1, 0.5, 4, 5, 0.9, 6, 70, 8, UnknownEnum.Value_m1, 0);
                    _hitbox.hit_vfx_style = UnknownEnum.Value_1;
                    _hitbox.hit_sfx = 5;
                }
                
                if (attack_frame == 4)
                    anim_frame = 6;
                
                if (attack_frame == 0)
                {
                    anim_frame = 7;
                    attack_phase++;
                    attack_frame = attack_connected() ? 15 : 22;
                }
                
                break;
            
            case 2:
                friction_gravity(ground_friction, grav, max_fall_speed);
                
                if (attack_frame <= 15)
                    anim_frame = 8;
                
                if (attack_frame <= 10)
                    anim_frame = 9;
                
                if (attack_frame <= 5)
                    anim_frame = 10;
                
                if (attack_frame == 0)
                {
                    attack_stop(UnknownEnum.Value_0);
                    run = false;
                }
                
                break;
        }
    }
    
    move_grounded();
}

enum UnknownEnum
{
    Value_m1 = -1,
    Value_0,
    Value_1,
    Value_2,
    Value_27 = 27
}
