if (window_fade != 0 && room != rm_init && !disable)
{
    var screen_width = setting().screen_width;
    var screen_height = setting().screen_height;
    var _p = 48;
    draw_set_alpha(window_fade / 4);
    draw_set_color(c_black);
    draw_rectangle(0, 0, screen_width, screen_height, false);
    draw_set_alpha(window_fade);
    draw_set_color(#0A1117);
    draw_rectangle(0, 0, screen_width, bar_height, false);
    draw_set_alpha(button_exit_fade);
    draw_set_color(c_red);
    draw_rectangle(screen_width - (_p * 1), 0, screen_width, bar_height, false);
    draw_sprite_ext(spr_window_buttons, 0, screen_width - (_p * 1), 0, 1, 1, 0, c_white, window_fade);
    
    if (!setting().fullscreen)
    {
        draw_set_alpha(button_full_fade);
        draw_set_color(c_ltgray);
        draw_rectangle(screen_width - (_p * 2), 0, screen_width - (_p * 1), bar_height, false);
        var _image = (full_toggle == true) ? 2 : 1;
        draw_sprite_ext(spr_window_buttons, _image, screen_width - (_p * 2), 0, 1, 1, 0, c_white, window_fade);
        draw_set_alpha(button_minimize_fade);
        draw_set_color(c_ltgray);
        draw_rectangle(screen_width - (_p * 3), 0, screen_width - (_p * 2), bar_height, false);
        draw_sprite_ext(spr_window_buttons, 3, screen_width - (_p * 3), 0, 1, 1, 0, c_white, window_fade);
    }
    
    draw_set_alpha(window_fade);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_set_font(fnt_window);
    draw_text(8, bar_height div 2, "A Few Quick Matches 1.1.0 [MODDED CLIENT]");
    draw_set_alpha(1);
}
