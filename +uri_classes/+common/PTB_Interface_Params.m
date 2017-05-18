classdef PTB_Interface_Params
    %PTB_INTERFACE_PARAMS 
    %   Parameters for a Psychtoolbox-based experiment view \ presenter

    properties (Constant)
        DEBUG_LEVEL_DEBUG = 'debug';
        DEBUG_LEVEL_HIGH = 'high';
        DEBUG_LEVEL_LOW = 'low';
        STEREO_DISPLAY_NONE = 0;
        STEREO_DISPLAY_SPLITSCREEN = 4;
        STEREO_DISPLAY_LEFT_RED_RIGHT_BLUE = 8;
        BLEND_FUNCTION_SRC_ALPHA = 'src_alpha';
        BLEND_FUNCTION_NONE = 'none';
    end
    
    properties
        screenNum = 2;
        debugLevel = uri_classes.common.PTB_Interface_Params.DEBUG_LEVEL_HIGH; % debug(highest)\high\low
        textSize = 12;
        textFont = 'Ariel';
        bgColor = [0 0 0];
        specifyRes = false;
        newWidth = -1;
        newHeight = -1;
        newHz = -1;
        stereoType = uri_classes.common.PTB_Interface_Params.STEREO_DISPLAY_NONE;
        anaglyph_red_gains = [0.8 0.0 0.0]; % for left eye in display mode 8
        anaglyph_blue_gains = [0.0 0.0 1.0]; % for right eye in display mode 8
        blendFunction = uri_classes.common.PTB_Interface_Params.BLEND_FUNCTION_NONE;
    end
    

    
    methods
    end
    
end

