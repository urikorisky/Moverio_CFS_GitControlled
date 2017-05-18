classdef PTB_GUI_Initializer < handle
    %PTB_GUI_INITIALIZER 
    % This is a static class that initializes PsychToolBox's parameters for display
    
    properties
    end
    
    methods (Static)
        function [ptb_window,windowRect,status] = initPTB(PTB_interface_params)
            import uri_classes.common.PTB_Interface_Params;
            status=1;
            prms = PTB_interface_params;
            
            % Set PTB debug level:
            switch(prms.debugLevel)
                case PTB_Interface_Params.DEBUG_LEVEL_HIGH
                    Screen('Preference','VisualDebugLevel',2);
                    Screen('Preference','SkipSyncTests',0);
                case PTB_Interface_Params.DEBUG_LEVEL_LOW
                    Screen('Preference','VisualDebugLevel',1);
                    Screen('Preference','SkipSyncTests',1);
                case PTB_Interface_Params.DEBUG_LEVEL_DEBUG
                    Screen('Preference','VisualDebugLevel',4);
                    Screen('Preference','SkipSyncTests',0);
                    Screen('Preference', 'Verbosity', 4);
                otherwise
                    
            end
            
            % Change screen resolution if specified:
            if (prms.specifyRes)
                % try setting the resolution of the screen. Should add error handling here!!!
                if(prms.newHz>0)
                    Screen('Resolution', prms.screenNum ,prms.newWidth,prms.newHeight,prms.newHz)
                else
                    Screen('Resolution', prms.screenNum ,prms.newWidth,prms.newHeight)
                end
            end
            
            % Open the new screen:
%             [ptb_window,windowRect] = Screen('OpenWindow',prms.screenNum,prms.bgColor,[],[],[],prms.stereoType);
            [ptb_window,windowRect] = PsychImaging('OpenWindow',prms.screenNum,prms.bgColor,[],[],[],prms.stereoType);
            
            
            % Set priority for script execution to realtime priority:
            priorityLevel=MaxPriority(ptb_window);
            Priority(priorityLevel);

            % Flip interval:
            if (strcmp(prms.debugLevel,PTB_Interface_Params.DEBUG_LEVEL_DEBUG))
                [ifi nvalid stddev]= Screen('GetFlipInterval', ptb_window, 100, 0.00005, 20);
                % 2DO - return these values if needed
            else
                ifi = 1/60;
                fps = round(1/ifi);
            end
            
            % Anaglyph gains, if needed:
            if (strcmp(prms.stereoType,PTB_Interface_Params.STEREO_DISPLAY_LEFT_RED_RIGHT_BLUE))
                SetAnaglyphStereoParameters('LeftGains', ptb_window, prms.anaglyph_red_gains);
                SetAnaglyphStereoParameters('RightGains', ptb_window,prms.anaglyph_blue_gains);
            end
            
            % Blend function change, if needed:
            if (~strcmp(prms.blendFunction,PTB_Interface_Params.BLEND_FUNCTION_NONE))
                switch (prms.blendFunction)
                    case PTB_Interface_Params.BLEND_FUNCTION_SRC_ALPHA
                        Screen('BlendFunction', ptb_window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                end
            end
            
            % Keyboard stuff:
            KbName('UnifyKeyNames');
            FlushEvents('keyDown');
            
            % Mouse stuff:
            mouseDeviceInd = GetMouseIndices();
            % if found more than one mouse, take the first one:
            mouseDeviceInd = mouseDeviceInd(1);
            % Ver06: hide mouse cursor on screen visible to subject:
            HideCursor(prms.screenNum);
            
            status = 0; % initialization was successful
        end
    end
    
end

