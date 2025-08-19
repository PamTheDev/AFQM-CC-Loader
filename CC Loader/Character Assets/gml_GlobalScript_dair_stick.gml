function dair_stick()
{
    var run = true;
    var _phase = (argument_count > 0) ? argument[0] : attack_phase;
    attack_frame = max(--attack_frame, 0);
    friction_gravity(air_friction, grav, max_fall_speed);
    fastfall_try();
    aerial_drift();
    
    if (run && cancel_ground_check())
        run = false;
    
    if (run)
    {
        switch (_phase)
        {
            case UnknownEnum.Value_m1:
                anim_sprite = spr_stick_dair;
                anim_speed = 0;
                anim_frame = 0;
                landing_lag = 16;
                speed_set(0, -1, true, true);
                attack_frame = 9;
                hurtbox_anim_match(877);
                collision_box_change(214);
                exit;
            
            case 0:
                if (attack_frame == 5)
                    anim_frame = 1;
                
                if (attack_frame == 0)
                {
                    anim_frame = 2;
                    attack_phase++;
                    attack_frame = 14;
                    var _hitbox = hitbox_create_melee(0, 28, 0.6, 1, 1, 6, 0, 2, 270, 13, UnknownEnum.Value_m1, 0, UnknownEnum.Value_13);
                    _hitbox.hit_vfx_style = UnknownEnum.Value_0;
                    _hitbox.hit_sfx = 63;
                    _hitbox.di_angle = 0;
                    _hitbox.asdi_multiplier = 0.5;
                    _hitbox.techable = false;
                    _hitbox.background_clear_allow = false;
                }
                
                break;
            
            case 1:
                if (attack_frame == 10)
                    anim_frame = 3;
                
                if (attack_frame == 7)
                    anim_frame = 4;
                
                if (attack_frame == 4)
                    anim_frame = 5;
                
                if ((attack_frame % 3) == 0 && attack_frame > 2)
                    hitbox_group_reset(0);
                
                if (attack_frame == 2)
                {
                    anim_frame = 6;
                    var _hitbox = hitbox_create_melee(0, 28, 0.6, 1.1, 4, 6, 1, 12, 45, 3, UnknownEnum.Value_m1, 1);
                    _hitbox.hit_vfx_style = UnknownEnum.Value_1;
                    _hitbox.hit_sfx = 143;
                }
                
                if (attack_frame == 0)
                {
                    anim_frame = 7;
                    attack_phase++;
                    attack_frame = 4;
                }
                
                break;
            
            case 2:
                if (attack_frame == 3)
                    anim_frame = 8;
                
                if (attack_frame == 0)
                {
                    attack_stop(UnknownEnum.Value_9);
                    run = false;
                }
                
                break;
        }
    }
    
    move();
    
    if (run)
        hurtbox_anim_match(877);
}

enum UnknownEnum
{
    Value_m1 = -1,
    Value_0,
    Value_1,
    Value_9 = 9,
    Value_13 = 13
}
