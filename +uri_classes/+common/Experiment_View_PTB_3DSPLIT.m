classdef Experiment_View_PTB_3DSPLIT < uri_classes.common.Experiment_View_PTB
    %EXPERIMENT_VIEW_PTB_3DSPLIT 
    %   An extension of the Experiment_View_PTB class with methods and tests specific to split-screen 3D
    %   display (e.g. Epson's MOVERIO glasses)
    
    properties
        eyesDistDelta = 0; % correction of the distance between the eyes as a factor of the focal point Z position
        lt_eye_rect @double;
        rt_eye_rect @double;
        
        winWidth @double; % width of display screen of one eye (both should be identical...)
        winHeight @double;
        
        breakLoopFlag @logical; % If to stop a presentation loop of a textures sequence. This is provided
                                % to allow stopping of a sequence from
                                % outside the loop.
    end
    
    methods
        
        function initGUI(this,PTB_interface_params)
            PTB_interface_params.stereoType = uri_classes.common.PTB_Interface_Params.STEREO_DISPLAY_SPLITSCREEN;
            PTB_interface_params.blendFunction = uri_classes.common.PTB_Interface_Params.BLEND_FUNCTION_SRC_ALPHA;
            initGUI@uri_classes.common.Experiment_View_PTB(this,PTB_interface_params);
            this.updateLtRtRects();
        end
        
        function sequenceLog = displayTexturesSequence_NoResponse(this,lt_textures_and_frames,rt_textures_and_frames,varargin)
            % receives an Mx2 matrix of [texture PTB ID, texture frame #], and shows it.
            % If there's more than two parameters, they are treated the
            % following way:
            % * extra parameter #1: an Nx2 matrix of [customEventID, frame #],
            % which calls the "onCustomEvent" function
            % * extra parameter #2: a number N which determines if there is any
            % kind of response check. If larger than 0, response check will
            % be made every N cycles of the loop, and the function 
            % "onResponseDuringSeq" will be called with the response
            % description.
            % * extra parameter #3: deviceNum for response, if parameter #2
            % exists.
            %
            % output: a struct containing the following properties:
            % * startTime - timestamp of beginning of sequence presentation.
            % This is NOT the time of the first flip. It is earlier.
            % * endTime - timestamp of end of sequence presentation. This
            % is NOT the time of the last flip. It is later.
            % * duration - the difference between the start and end times.
            % This is NOT the difference between the first and last flip
            % times. It is longer.
            % * flipTimes - of all the frames in the sequence
            % * lt_flipTimes - flip times of all the textures displayed to
            % the left eye
            % * rt_flipTimes - flip times of all the textures displayed to
            % the right eye
            % * events_flipTimes - flip times of all the events that
            % happenned during the sequence
            sequenceLog = struct('startTime',[],'endTime',[],...
                'duration',[],'flipTimes',[],...
                'lt_flipTimes',[],'rt_flipTimes',[],...
                'events_flipTimes',[]);
            customEvents_IDs_and_frames = [0 0];
            if (numel(varargin)>0)
                customEvents_IDs_and_frames = varargin{1};
            end
            checkResp = false;
            if (numel(varargin)>1)
                checkResp = true;
                iterationsRespCheck = varargin{2};
                deviceNum = 1;
                sequenceLog.pressed = false;
                sequenceLog.firstPressTimes = [];
            end
            if (numel(varargin)>2)
                deviceNum = varargin{3};
            end
            startTime = GetSecs();
            
            numFrames = max(lt_textures_and_frames(end,2),rt_textures_and_frames(end,2));
            flipTimes = zeros(numFrames,2);
            lt_flipTimes = zeros(size(lt_textures_and_frames,1),1);
            rt_flipTimes = zeros(size(rt_textures_and_frames,1),1);
            events_flipTimes = zeros(size(customEvents_IDs_and_frames,1),1);
            
            diffs = zeros(1,numFrames);
            
            this.breakLoopFlag = false;
            for iFrame = 1:numFrames
                tic;
                if (this.breakLoopFlag)
                    break;
                end
%                 fprintf('frame %d, left_next_frame %d, right_next_frame %d, left_tex %d, right tex %d\n',iFrame,lt_textures_and_frames(1,2),rt_textures_and_frames(1,2),lt_textures_and_frames(1,1),rt_textures_and_frames(1,1));
                ltChange = false; rtChange = false; eventInFrame = false;
                if (iFrame == lt_textures_and_frames(1,2))
                    ltChange = true;
                end
                if (iFrame == rt_textures_and_frames(1,2))
                    rtChange = true;
                end
                
                if (ltChange || rtChange)
                    Screen('SelectStereoDrawBuffer', this.ptb_window, 0);
                    % fill screen with background color to erase
                    % semi-transparent influences:
                    Screen('FillRect', this.ptb_window ,this.displayBuildParameters.bgColor);
                    Screen('DrawTexture',this.ptb_window,lt_textures_and_frames(1,1),[],this.lt_eye_rect);
                    Screen('SelectStereoDrawBuffer', this.ptb_window, 1);
                    Screen('FillRect', this.ptb_window ,this.displayBuildParameters.bgColor);
                    Screen('DrawTexture',this.ptb_window,rt_textures_and_frames(1,1),[],this.rt_eye_rect);
                    flipTimes(iFrame,1) = Screen('Flip',this.ptb_window);
                    flipTimes(iFrame,2) = ltChange+2*rtChange+100*flipTimes(iFrame,2);
                    Screen('SelectStereoDrawBuffer', this.ptb_window, 0); %draw on the other side as well!
                    Screen('FillRect', this.ptb_window ,this.displayBuildParameters.bgColor);
                    Screen('DrawTexture',this.ptb_window,lt_textures_and_frames(1,1),[],this.lt_eye_rect);
                    Screen('SelectStereoDrawBuffer', this.ptb_window, 1);
                    Screen('FillRect', this.ptb_window ,this.displayBuildParameters.bgColor);
                    Screen('DrawTexture',this.ptb_window,rt_textures_and_frames(1,1),[],this.rt_eye_rect);

                    if (ltChange)
                        lt_flipTimes(size(lt_flipTimes,1)-size(lt_textures_and_frames,1)+1) = flipTimes(iFrame,1);
                        if(size(lt_textures_and_frames,1)>1)
                            lt_textures_and_frames(1,:)=[];
                        end
                    end
                    if (rtChange)
                        rt_flipTimes(size(rt_flipTimes,1)-size(rt_textures_and_frames,1)+1) = flipTimes(iFrame,1);
                        if(size(rt_textures_and_frames,1)>1)
                            rt_textures_and_frames(1,:)=[];
                        end
                    end
                else
                    flipTimes(iFrame,1) = Screen('Flip',this.ptb_window,[],1); % flip without changing the screen
                    flipTimes(iFrame,2) = 4+100*flipTimes(iFrame,2);
                end
                
                if (iFrame == customEvents_IDs_and_frames(1,2))
                    this.onCustomEvent(customEvents_IDs_and_frames(1,1));
                    events_flipTimes(size(events_flipTimes,1)-size(customEvents_IDs_and_frames,1)+1) = flipTimes(iFrame,1);
                    if(size(customEvents_IDs_and_frames,1)>1)
                            customEvents_IDs_and_frames(1,:)=[];
                    end
                end
                
                if (checkResp)
                    % If we want to check responses even though this
                    % function is supposed to work without this
                    % functionality:
                    if (mod(iFrame,iterationsRespCheck)==0)
                        % We check once every N iterations, that is N flips
                        % of the screen in our case. N=iterationsRespCheck.
                        % This way we can at least not perform this check
                        % EVERY iteration.
                        [ pressed, firstPressTimes]=PsychHID('KbQueueCheck',deviceNum);
                        if (pressed)
                            % If a response was given, we won't know what
                            % it was on the outside since it's already
                            % removed from the queue by checking it (dumb
                            % but ok). So, we note that by keeping a
                            % documentation of it in the log:
                            sequenceLog.pressed = pressed;
                            sequenceLog.firstPressTimes = firstPressTimes;
                            % Run the proper handler function for such
                            % cases (implemnted inside the subclass):
                            this.onResponseDuringSeq(find(firstPressTimes));
                        end
                    end
                end
                
                diffs(iFrame) = toc;
            end
            endTime = GetSecs();
            duration = endTime-startTime;

            % set log data:
            sequenceLog.startTime = startTime;
            sequenceLog.endTime = endTime;
            sequenceLog.duration = duration;
            sequenceLog.flipTimes = flipTimes(:,1);
            sequenceLog.lt_flipTimes = lt_flipTimes;
            sequenceLog.rt_flipTimes = rt_flipTimes;
            sequenceLog.events_flipTimes = events_flipTimes;
        end
        
        function debugFliptimes(this,flipTimes)
            plot([0.017; diff(flipTimes(:,1))])
            hold on
            plot(0.017+0.001*flipTimes(:,2),'r.')            
        end
        
        function onCustomEvent(this,eventID)
            % left for the subclasses to implement
        end
        
        function onResponseDuringSeq(this,resp)
           % left for the subclasses to implement 
        end
        
        function sequenceLog = displayTexturesSequence_QueuedResponseSingle(this,lt_textures_and_frames,rt_textures_and_frames,deviceNum,varargin)
           % If there's more than three parameters, they are treated the
            % following way:
            % extra parmataer #1: an Nx2 matrix of [customEventID, frame #],
            % which calls the "onCustomEvent" function
            %
            % output: sequenceLog - struct containing the following fields:
            % * all the fields which are returned by displayTexturesSequence_NoResponse()
            % * keysPressed - ASCII codes(?) of the keys that were pressed
            % during the sequence
            % * firstPressTimes - in ms, for each key, when was the first
            % press time of this key relative to the start of the sequence
             customEvents_IDs_and_frames = [0 0];
            if (numel(varargin)>0)
                customEvents_IDs_and_frames = varargin{1};
            end           
            
            keysPressed = [];
            firstPressTimes = [];
            PsychHID('KbQueueCreate',deviceNum);
            PsychHID('KbQueueFlush',deviceNum);
            PsychHID('KbQueueStart',deviceNum);
            % Since KbQueueCreate contains some overhead (see
            % ftp://ftp.tuebingen.mpg.de/pub/pub_dahl/stmdev10_D/Matlab6/Toolboxes/Psychtoolbox/PsychDocumentation/KbQueue.html),
            % I try to solve this by pausing for a second:
            pause(1);
            sequenceLog = this.displayTexturesSequence_NoResponse(lt_textures_and_frames,rt_textures_and_frames,customEvents_IDs_and_frames,50,deviceNum);
            PsychHID('KbQueueStop',deviceNum);
            [ pressed, firstPressTimes]=PsychHID('KbQueueCheck',deviceNum);
            
            if (sequenceLog.pressed)
                % If we see no response, it might be because the inner
                % function caught it. Check that:
                pressed = true;
                firstPressTimes = sequenceLog.firstPressTimes;
            end
            
            if (pressed)
                keysPressed=find(firstPressTimes);
                firstPressTimes = firstPressTimes(keysPressed);
                firstPressTimes = firstPressTimes-sequenceLog.startTime;
            else
                disp('No Response!!!');
            end
            PsychHID('KbQueueRelease',deviceNum);
            
            % set the log fields:
            sequenceLog.keysPressed = keysPressed;
            sequenceLog.firstPressTimes = firstPressTimes;
        end
        
        function [eyesDistDelta,leftEyeDelta,rightEyeDelta,objDistCm] = runFusionCalibration(this,objDist)
            % Runs a calibration phase for determining the delta needed between the eyes when the subject
            % fixates on an object in a certain distance
            % * This function does not involve the presenter. It is specific to this display, and therefore I
            %   decided to make it independent. Consider redesign if needed.
            % * Since mouse wheel detection is not yet supported in PTB for windows, it isn't used here.
            %   Though I wanted to. But I can't.
            
            import uri_classes.common.PTB_KbConsts;
            
            objDistCm = objDist;

            % set the displays for left and right eyes:
            lineThickness = 10;
%             [leftEyeImage,orig_leftEyeDestRect] = this.createDashedLinesForFusion([0 0 1],lineThickness,0);
%             [rightEyeImage,orig_rightEyeDestRect] = this.createDashedLinesForFusion([1 0 1],lineThickness,180);
            [leftEyeImage,orig_leftEyeDestRect] = this.createCrossForFusion(300,300,[0 1 0],4);
            [rightEyeImage,orig_rightEyeDestRect] = this.createCrossForFusion(300,300,[0 1 0],4);
            % make textures:
            leftEyeTexture = Screen('MakeTexture',this.ptb_window,leftEyeImage);
            rightEyeTexture = Screen('MakeTexture',this.ptb_window,rightEyeImage);
            
            eyesDistDelta=0;
            leftEyeDelta=0;
            rightEyeDelta=0;
            HorizCalibEnded = false;
            leftEyeDestRect = orig_leftEyeDestRect;
            rightEyeDestRect = orig_rightEyeDestRect;
            disp('Fusion test began');
%             FlushEvents('keyDown');
%             KbReleaseWait(-1);
            [~,orig_y] = GetMouse(this.ptb_window,this.MOUSE_DEVICE_NUMBER);
            while (~HorizCalibEnded)
                % update lines distance from center:
                leftEyeDestRect([1,3])=orig_leftEyeDestRect([1,3])+eyesDistDelta;
                rightEyeDestRect([1,3])=orig_rightEyeDestRect([1,3])-eyesDistDelta;
                % Draw the lines:
                Screen('SelectStereoDrawBuffer', this.ptb_window, 0);
                Screen('DrawTexture',this.ptb_window,leftEyeTexture,[],leftEyeDestRect);
                Screen('SelectStereoDrawBuffer', this.ptb_window, 1);
                Screen('DrawTexture',this.ptb_window,rightEyeTexture,[],rightEyeDestRect);
                Screen('Flip',this.ptb_window);
                [~,y,buttons] = this.waitMouseChange;
                eyesDistDelta = orig_y-y;
                if(sum(buttons)>0)
                    HorizCalibEnded = true;
                end
%                 [~,keyCode]=KbWait(-1);
%                 switch (find(keyCode))
%                     case PTB_KbConsts.DOWN
%                         eyesDistDelta = eyesDistDelta+1;
%                     case PTB_KbConsts.UP
%                         eyesDistDelta = eyesDistDelta-1;
%                     case PTB_KbConsts.ESC
%                         HorizCalibEnded = true;
%                     case PTB_KbConsts.ENTER
%                         HorizCalibEnded = true;
%                 end
                

            end
            
            this.eyesDistDelta = eyesDistDelta;
            this.updateLtRtRects();
            
            % draw frames to assure fusion:
            Screen('SelectStereoDrawBuffer', this.ptb_window, 0);
            Screen('FrameRect', this.ptb_window ,[255 0 0] ,this.lt_eye_rect ,10);
            Screen('DrawLine', this.ptb_window ,[255 0 0] , this.lt_eye_rect(1), this.lt_eye_rect(2), this.lt_eye_rect(3), this.lt_eye_rect(4),5);
            Screen('DrawLine', this.ptb_window ,[255 0 0] , this.lt_eye_rect(1), this.lt_eye_rect(4), this.lt_eye_rect(3), this.lt_eye_rect(2),5);
            Screen('SelectStereoDrawBuffer', this.ptb_window, 1);
            Screen('FrameRect', this.ptb_window ,[255 0 0] ,this.rt_eye_rect ,10);
            Screen('DrawLine', this.ptb_window ,[255 0 0] , this.rt_eye_rect(1), this.rt_eye_rect(2), this.rt_eye_rect(3), this.rt_eye_rect(4),5);
            Screen('DrawLine', this.ptb_window ,[255 0 0] , this.rt_eye_rect(1), this.rt_eye_rect(4), this.rt_eye_rect(3), this.rt_eye_rect(2),5);
            Screen('Flip',this.ptb_window);
            
            disp('Fustion test ended');
        end
        
        function [bmp,destRect] = createCrossForFusion(this,height,width,color,lineThickness)
            shape = zeros(height,width);
            shape(round(height/2-lineThickness/2):round(height/2+lineThickness/2),1:width) = 1;
            shape(1:height,round(width/2-lineThickness/2):round(width/2+lineThickness/2)) = 1;
            bmp = zeros(height,width,3);
            for iCol=1:3
                bmp(:,:,iCol)=color(iCol)*shape;
            end
            % convert images to PTB-readable colors:
            bmp = bmp*255;
            
            crossTextureRect = [0,0,width,height];
            destRect = CenterRectOnPointd(crossTextureRect,this.screenCenter(1),this.screenCenter(2));
        end
        
        function [bmp,destRect] = createDashedLinesForFusion(this,color,lineThickness,phase)
            % dashed line segment length and thickness:
            numSegs = 20;
            dashedSegLen = floor(this.screenHeight/numSegs/2);
            segment = [ones(dashedSegLen,lineThickness);zeros(dashedSegLen,lineThickness)];
            segment = circshift(segment,round(phase/360*dashedSegLen));
            bmp = zeros(this.screenHeight,lineThickness,3);
            % Set color:
            for iCol = 1:3
                bmp([1:numSegs*2*dashedSegLen],:,iCol)=color(iCol)*repmat(segment,numSegs,1);
            end
            % convert images to PTB-readable colors:
            bmp = bmp*255;
            linesTexturesRects = [0,0,lineThickness,this.screenHeight];
            destRect = CenterRectOnPointd(linesTexturesRects,this.screenCenter(1),this.screenCenter(2));
        end
        
        function updateLtRtRects(this)
            % updates the rects for left and right eyes. This is done in one-shot instead of being calculated
            % on every drawing, to save CPU power
            newHalfWidth = this.screenWidth/2-this.eyesDistDelta;
            this.lt_eye_rect = this.windowRect;
            this.lt_eye_rect(1) = this.screenCenter(1)+this.eyesDistDelta-newHalfWidth;
            this.lt_eye_rect(3) = this.screenCenter(1)+this.eyesDistDelta+newHalfWidth;
            this.rt_eye_rect = this.windowRect;
            this.rt_eye_rect(1) = this.screenCenter(1)-this.eyesDistDelta-newHalfWidth;
            this.rt_eye_rect(3) = this.screenCenter(1)-this.eyesDistDelta+newHalfWidth;
        end
        
        function width = get.winWidth(this)
            width = this.lt_eye_rect(3) - this.lt_eye_rect(1);
        end

        function height = get.winHeight(this)
            height = this.lt_eye_rect(4) - this.lt_eye_rect(2);
        end
        
    end
    
end