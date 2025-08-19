validCharacters = ["eureka", "knockt", "rend", "pulse", "stick"];
charactersPerRow = 4;
spacing_x = 40;
spacing_y = 0;
portraitObjects = [];
portraitsCreated = false;
function createPortraits()
{
    var max_width = sprite_width;
    var max_height = sprite_height;
    var p_width_default = sprite_get_width(spr_css_portrait_eureka);
    var p_height_default = sprite_get_height(spr_css_portrait_eureka);
    var p_scale = min(max_width / p_width_default, max_height / p_height_default, 1);
    var p_width = p_width_default * p_scale;
    var p_height = p_height_default * p_scale;
    var validCharIds = [];
    
    for (var i = 0; i < array_length(validCharacters); i++)
    {
        for (var j = 0; j < character_count(); j++)
        {
            if (character_data_get(j, UnknownEnum.Value_0) == validCharacters[i])
            {
                array_insert(validCharIds, min(array_length(validCharIds), i), j);
                break;
            }
        }
    }
    
    var rowChars = 0;
    var rowNumber = 0;
    var xx = 0;
    var yy = max_height / ((array_length(validCharacters) / charactersPerRow) * 2);
    var remainingCharacters = array_length(validCharIds);
    
    for (var c = 0; c < array_length(validCharIds); c++)
    {
        if ((rowChars % charactersPerRow) == 0)
        {
            rowNumber += 1;
            xx = 0;
            
            if ((array_length(validCharIds) % 2) != 0)
                xx += (p_width / 2);
            
            xx += ((min(remainingCharacters, charactersPerRow) / 2) * (p_width + spacing_x));
            
            if (rowChars != 0)
                yy += (p_height * 0.95);
        }
        
        var newPortrait = instance_create_layer(xx + x, yy + y, layer, obj_css_portrait);
        var characterName = character_data_get(validCharIds[c], UnknownEnum.Value_0);
        array_push(portraitObjects, newPortrait);
        
        if (characterName == validCharacters[0])
            global.cpuDefaultPortrait = newPortrait;
        
        newPortrait.character = characterName;
        newPortrait.sprite = character_data_get(validCharIds[c], UnknownEnum.Value_2);
        newPortrait.defaultScale = p_scale;
        
        if (room == rm_css)
        {
            var data = engine().css_player_data;
            
            if (array_length(data) != 0)
            {
                if (array_length(global.cssPortraits) != 0)
                {
                    for (var i = 0; i < array_length(data); i++)
                    {
                        var p = obj_css.players[i];
                        
                        if (global.cssPortraits != [])
                        {
                            if (global.cssPortraits[i] == newPortrait.character)
                            {
                                p.hoveredPortrait = newPortrait;
                                p.hoveredPortrait.hovered++;
                            }
                        }
                    }
                }
            }
        }
        
        xx += (spacing_x + p_width);
        rowChars += 1;
        remainingCharacters -= 1;
    }
    
    portraitsCreated = true;
}

enum UnknownEnum
{
    Value_0,
    Value_2 = 2
}
