classdef Experiment_View_PTB < uri_classes.common.Experiment_View
    %EXPERIMENT_VIEW_PTB Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        displayBuildParameters @uri_classes.common.PTB_Interface_Params;
        ptb_window @double;
        windowRect @double;
        KEYBOARD_DEVICE_NUMBER = -1;
        MOUSE_DEVICE_NUMBER = 1;
    end
    
    properties %(Access = protected)
        screenCenter @double;
        screenHeight @double;
        screenWidth @double;
    end
    
    methods
        
        function this = Experiment_View_PTB()

        end

        function initGUI(this,PTB_interface_params)
            this.displayBuildParameters = PTB_interface_params;
            [this.ptb_window,this.windowRect,status] = uri_classes.common.PTB_GUI_Initializer.initPTB(this.displayBuildParameters);
        end
        
        function displayTexturesSequence_NoResponse(this,textures_and_frames)
            % receives an Mx2 matrix of [texture PTB ID, texture frame #], and shows it.
            for iFrame = 1:textures_and_frames(end,2)
                if (iFrame == textures_and_frames(1,2))
                    Screen('DrawTexture',this.ptb_window,textures_and_frames(1,1));
                    Screen('Flip',this.ptb_window);
                    Screen('DrawTexture',this.ptb_window,textures_and_frames(1,1)); % draw on the other side of the screen as well. This could be very resource-consuming if we present something that changes in the same FPS as the screen...
                    textures_and_frames(1,:)=[];
                else
                    Screen('Flip',this.ptb_window,[],1); % flip without changing the buffers
                end
            end
        end
        
        function [pressTime,keyPressed] = pendSpecificKeys(this,varargin)
            RestrictKeysForKbCheck([varargin{:}]);
            [pressTime,keyPressed] = KbWait(this.KEYBOARD_DEVICE_NUMBER,2);
            RestrictKeysForKbCheck([]);
        end
        
        function [x,y,buttons] = waitMouseChange(this)
            [start_x,start_y,start_buttons,focus,valuators,valinfo] = GetMouse(this.ptb_window, this.MOUSE_DEVICE_NUMBER);
            x = start_x; y=start_y; buttons=start_buttons;
            while((x==start_x)&&(y==start_y)&&(isequal(buttons,start_buttons)))
                [x,y,buttons,focus,valuators,valinfo] = GetMouse(this.ptb_window, this.MOUSE_DEVICE_NUMBER);
            end
        end
        
        function [centerPoint] = get.screenCenter(this)
            centerPoint = [0,0];
            if (isempty(this.ptb_window))
                return;
            end
            centerPoint = [this.windowRect(3)/2, this.windowRect(4)/2];
        end
        
        function [width] = get.screenWidth(this)
            width = 0;
            if (isempty(this.ptb_window))
                return;
            end
            width = this.windowRect(3)-this.windowRect(1);
        end
        
        function [height] = get.screenHeight(this)
            height = 0;
            if (isempty(this.ptb_window))
                return;
            end
            height = this.windowRect(4)-this.windowRect(2);
        end
        
    end
    
end

