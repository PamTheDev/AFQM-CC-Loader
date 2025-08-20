function dspec_stick()
{
    var run = true;
    var _phase = (argument_count > 0) ? argument[0] : attack_phase;
    attack_frame = max(--attack_frame, 0);
    
    if (run)
    {
        switch (_phase)
        {
            case UnknownEnum.Value_m1:
                anim_sprite = spr_stick_dspec;
                anim_frame = 0;
                anim_speed = 0;
                
                if (!on_ground())
                {
                    attack_frame = 18;
                    attack_phase = 0;
                    speed_set(0, 0, true, false);
                }
                else
                {
                    speed_set(2 * facing, -4.5, false, false);
                    attack_frame = 18;
                    attack_phase = 3;
                }
                
                ex_move_reset();
                exit;
            
            case 0:
                ex_move_allow(1);
                
                if (attack_frame == 12)
                    anim_frame = 1;
                
                if (attack_frame == 6)
                    anim_frame = 2;
                
                if (attack_frame == 3)
                    anim_frame = 3;
                
                if (attack_frame == 0)
                {
                    anim_frame = 4;
                    attack_phase++;
                    attack_frame = 90;
                    var _hitbox = hitbox_create_melee(16, 32, 0.6, 0.6, 6, 7, 0.4, 9, 290, 90, UnknownEnum.Value_m2, 0);
                    _hitbox.hit_restriction = UnknownEnum.Value_2;
                    _hitbox.di_angle = 0;
                    _hitbox.drift_di_multiplier = 0;
                    _hitbox.asdi_multiplier = 0;
                    _hitbox.hit_vfx_style = UnknownEnum.Value_1;
                    _hitbox.hit_sfx = 143;
                    _hitbox = hitbox_create_melee(16, 32, 0.6, 0.6, 6, 7, 0.4, 9, 0, 90, UnknownEnum.Value_m2, 0);
                    _hitbox.hit_restriction = UnknownEnum.Value_1;
                    _hitbox.hit_vfx_style = UnknownEnum.Value_1;
                    _hitbox.hit_sfx = 5;
                    _hitbox.knockback_state = UnknownEnum.Value_26;
                }
                
                break;
            
            case 1:
                if ((attack_frame % 2) == 0)
                {
                    anim_frame++;
                    
                    if (anim_frame > 4)
                        anim_frame = 4;
                }
                
                if (check_wall_jump())
                {
                    attack_stop_preserve_state();
                    exit;
                }
                
                speed_set(1.5 * facing, 12, false, false);
                
                if (on_ground())
                {
                    anim_frame = 5;
                    speed_set(0, 0, true, false);
                    hitbox_destroy_attached_all();
                    
                    if (ex_move_is_activated())
                    {
                        camera_shake(1, 10);
                        var _hitbox = hitbox_create_melee(8, 12, 0.6, 0.4, 4, 13, 0.9, 20, 55, 7, UnknownEnum.Value_m1, 1, UnknownEnum.Value_4);
                        _hitbox.hit_sfx = 36;
                        _hitbox.hit_vfx_style = [UnknownEnum.Value_25, UnknownEnum.Value_2, UnknownEnum.Value_26];
                        _hitbox.knockback_state = UnknownEnum.Value_27;
                        _hitbox = hitbox_create_melee(0, 0, 7, 20, 4, 13, 0.9, 20, 55, 3, UnknownEnum.Value_m2, 1, UnknownEnum.Value_4);
                        _hitbox.hit_sfx = 5;
                        _hitbox.hit_vfx_style = [UnknownEnum.Value_2, UnknownEnum.Value_26];
                        _hitbox.hit_restriction = UnknownEnum.Value_1;
                    }
                    else
                    {
                        camera_shake(0, 6);
                        var _hitbox = hitbox_create_melee(8, 12, 0.6, 0.4, 4, 13, 0.4, 17, 55, 7, UnknownEnum.Value_m1, 1);
                        _hitbox.hit_sfx = 36;
                        _hitbox.hit_vfx_style = [UnknownEnum.Value_25, UnknownEnum.Value_2];
                        _hitbox.knockback_state = UnknownEnum.Value_27;
                        _hitbox.hitstun_scaling = 0.75;
                        _hitbox.shieldstun_scaling = 0.1;
                        _hitbox = hitbox_create_melee(13, 20, 3.4, 0.3, 1, 11, 0.3, 12, 90, 3, UnknownEnum.Value_m1, 1);
                        _hitbox.hit_sfx = 63;
                        _hitbox.hit_vfx_style = UnknownEnum.Value_1;
                        _hitbox.custom_hitstun = 35;
                        _hitbox.hit_restriction = UnknownEnum.Value_1;
                        _hitbox.shieldstun_scaling = 0;
                    }
                    
                    attack_phase = 2;
                    attack_frame = 30;
                    run = false;
                }
                
                if (run && (attack_connected() || attack_frame <= 80) && cancel_jump_check())
                    exit;
                
                if (attack_frame == 0)
                    attack_stop(UnknownEnum.Value_24);
                
                break;
            
            case 2:
                friction_gravity(ground_friction, grav, max_fall_speed);
                
                if (cancel_air_check())
                    exit;
                
                if (attack_frame == 18)
                    anim_frame = 7;
                
                if (attack_frame == 16)
                    anim_frame = 8;
                
                if (attack_frame == 14)
                    anim_frame = 9;
                
                if (attack_frame == 12)
                    anim_frame = 10;
                
                if (attack_frame == 8)
                    anim_frame = 11;
                
                if (attack_frame == 4)
                    anim_frame = 12;
                
                if (attack_frame == 0)
                    attack_stop(UnknownEnum.Value_0);
                
                break;
            
            case 3:
                ex_move_allow(1);
                
                if (attack_frame == 8)
                    anim_frame = 1;
                
                if (attack_frame == 4)
                    anim_frame = 2;
                
                if (attack_frame == 0)
                {
                    attack_phase = 0;
                    speed_set(0, 0, false, false);
                    attack_frame = 3;
                }
                
                break;
        }
    }
    
    move_hit_platforms();
}

enum UnknownEnum
{
    Value_m2 = -2,
    Value_m1,
    Value_0,
    Value_1,
    Value_2,
    Value_4 = 4,
    Value_24 = 24,
    Value_25,
    Value_26,
    Value_27
}
