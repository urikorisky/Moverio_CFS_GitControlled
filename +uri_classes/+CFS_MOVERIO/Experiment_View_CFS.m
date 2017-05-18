classdef Experiment_View_CFS < uri_classes.common.Experiment_View_PTB_3DSPLIT 
    %EXPERIMENT_VIEW_CFS 
    % The View component of the Moverio CFS experiment
    
    properties
        domEye='r'; %The eye to which the mondrians are presented. either l=left or r=right(default).
%         mondrianImageProps @uri_classes.CFS_MOVERIO.Mondrian_Image_Properties;
        cfsProps @uri_classes.CFS_MOVERIO.CFS_texSeq_Properties;
        mondTextures = [];
        overlayTextures = [];
        propsForTransparentFixation @uri_classes.CFS_MOVERIO.CFS_texSeq_Properties; % To show a fixation between trials, which derives its properties from the in-trial textures.
        transparentFixationTexture = [];
        
        currTrialMondrianSeq = [];
        currTrialOverlaySeq = [];
        
        devicesManager @uri_classes.common.Devices_Manager; % To control the other devices used to display to the subject. In this case, our LPT-activated device.
        LPT_port @char;
        moverioDelay @double; %in ms, how long is the delay between when a stimulus is sent until it is displayed on the MOVERIO glasses.
    end
    
    methods
        
        function this = Experiment_View_CFS()
            this.cfsProps = uri_classes.CFS_MOVERIO.CFS_texSeq_Properties(); % prepare a properties object with default properties.
            this.propsForTransparentFixation = uri_classes.CFS_MOVERIO.CFS_texSeq_Properties();
            this.devicesManager = uri_classes.CFS_MOVERIO.CFS_View_Devices_Manager();
            this.devicesManager.reactivateMagnet();
            this.createPropsMap({'MOVERIO_delay','LPT_Port_Number'},{'moverioDelay','LPT_port'});
        end
        
        function initGUI(this,PTB_interface_params)
            if (~exist('PTB_interface_params','var'))
                PTB_interface_params = uri_classes.common.PTB_Interface_Params;
            end
            initGUI@uri_classes.common.Experiment_View_PTB_3DSPLIT(this,PTB_interface_params);
        end
        
        function setCFSproperties(this,props)
            % Select mondrian type:
            switch(props.Mondrians_Shape)
                case 'circles'
                    mondProps = uri_classes.CFS_MOVERIO.Mondrian_Circles_Image_Properties();
                otherwise
                    % default is circles:
                    mondProps = uri_classes.CFS_MOVERIO.Mondrian_Circles_Image_Properties();
            end
            % set it with appropriate properties:
            mondProps.setProps(props);
            % put it into back into the info object:
            props.Mondrian_Props = mondProps;
            % and send this info object to the CFS properties object:
            this.cfsProps.setProps(props);
            % Also set properties for transparent, inter-trial fixation:
            this.propsForTransparentFixation.setProps(props);
            this.propsForTransparentFixation.timeToStartFade=0;
            this.propsForTransparentFixation.timeToEndFade=1;
            this.propsForTransparentFixation.totalTime=1;
            this.propsForTransparentFixation.overlayStartAlpha=0;
            
            
        end
        
        function [eyesDistDelta,leftEyeDelta,rightEyeDelta,objDistCm] = runFusionCalibration(this,objDist)
            this.devicesManager.dropShutter();
            [eyesDistDelta,leftEyeDelta,rightEyeDelta,objDistCm] = runFusionCalibration@uri_classes.common.Experiment_View_PTB_3DSPLIT(this,objDist);
        end
        
        function prepareAssets(this)
            disp('Preparing assets...');
            this.cfsProps.frameBMP = uri_classes.CFS_MOVERIO.CFS_texSeq_Factory.getFrameBMP(this.cfsProps);
            this.mondTextures = uri_classes.CFS_MOVERIO.CFS_Mondrian_texSeq_Factory.createMondrianTextures(...
                this.cfsProps,this.ptb_window,100);
            this.overlayTextures = uri_classes.CFS_MOVERIO.CFS_Overlay_texSeq_Factory.createOverlayFadeTextures(...
                this.cfsProps,this.ptb_window);
            
            this.propsForTransparentFixation.frameBMP = this.cfsProps.frameBMP;
            this.transparentFixationTexture = uri_classes.CFS_MOVERIO.CFS_Overlay_texSeq_Factory.createOverlayFadeTextures(...
                this.propsForTransparentFixation,this.ptb_window);
            disp('Assets ready');
        end
        
        function prepareCFStrial(this,trialProps)
            disp('Preparing trial');
            % prepare the next CFS trial for display
            this.currTrialMondrianSeq = uri_classes.CFS_MOVERIO.CFS_Mondrian_texSeq_Factory.createSeq(...
                trialProps,this.ptb_window,this.mondTextures,this.overlayTextures(1));
            this.currTrialOverlaySeq = uri_classes.CFS_MOVERIO.CFS_Overlay_texSeq_Factory.createSeq(...
                trialProps,this.ptb_window,this.overlayTextures);
        end
        
        function prepareCFStrial_defaultProps(this)
            this.prepareCFStrial(this.cfsProps);
        end
        
        function showBreakMessage(this,nextTrialsInfo)
            fprintf('Subject can now take a break for a couple of seconds. Can take off glasses and remove head from chin rest.\n');
            this.showThisTrialPropsAndUpcoming(nextTrialsInfo);
            fprintf('Press ENTER to end break.\n');
            this.pendSpecificKeys(uri_classes.common.PTB_KbConsts.ENTER);
        end
        
        function showThisTrialPropsAndUpcoming(this,trialsInfo)
            fprintf('\n******* CURRENT TRIAL: *******\n');
            this.showCmdWindowTrialProps(trialsInfo{1},'short');
            fprintf('******************************\n');
            fprintf('\n--- upcoming: ---\n');
            for iTrial=2:numel(trialsInfo)
                fprintf(['+' num2str(iTrial-1) ': ']);
                this.showCmdWindowTrialProps(trialsInfo{iTrial},'short');
            end
        end
        
        function showCmdWindowTrialProps(this,trialObj,format)
            switch(format)
                case 'short'
                    fprintf(['Trial #' num2str(trialObj.ID) ': %-20s%-20s%-20s\n'], ...
                        num2str(trialObj.stimName), ...
                        trialObj.level_names{2}, ...
                        trialObj.level_names{1});
                otherwise
                    fprintf(['Trial #' num2str(trialObj.ID) '\n'...
                        trialObj.conds_names{1} ': ' trialObj.level_names{1} '\n'...
                        trialObj.conds_names{2} ': ' trialObj.level_names{2} '\n'...
                        'Stimulus ID: ' num2str(trialObj.stimID) '\n'...
                        'Stimulus Name: ' num2str(trialObj.stimName) '\n'...
                        ]);
            end
        end
        
        function [timePressed,keyPressed] = pendExperimenterTrialStart(this)
            this.devicesManager.reactivateMagnet();
            disp('Press ESC to report mistake in last trial.');
            disp('Trial ready. Press ENTER to start.');
            [timePressed,keyPressed] = this.pendSpecificKeys(uri_classes.common.PTB_KbConsts.ENTER,uri_classes.common.PTB_KbConsts.ESC);
        end
        
        function [mistakeCode,comments] = getMistakeReportForTrial(this,trial)
            import uri_classes.CFS_MOVERIO.CFS_TrialMistakeCodes;
            comments = '';
            mistakeCode = [];
            disp('?---------------------------------------------------------------------------?');
            disp('?                       Trial Mistake Report Mode                           ?');
            disp('?---------------------------------------------------------------------------?');
            disp('Reporting mistake for trial:');
            this.showCmdWindowTrialProps(trial,'short');
            disp('Choose mistake type:');
            disp('(1)Wrong side  (2)Wrong stimulus  (3)Subject confused  (4)Other');
            [~,keyPressed] = this.pendSpecificKeys(KbName('1'),KbName('2'),KbName('3'),KbName('4'));
            commentsNeeded = false;
            switch(find(keyPressed))
                case KbName('1')
                    mistakeCode = CFS_TrialMistakeCodes.WRONG_SIDE;
                case KbName('2')
                    mistakeCode = CFS_TrialMistakeCodes.WRONG_STIMULUS;
                    commentsNeeded = true;
                case KbName('3')
                    mistakeCode = CFS_TrialMistakeCodes.SUBJECT_CONFUSED;
                    commentsNeeded = true;
                case KbName('4')
                    mistakeCode = CFS_TrialMistakeCodes.OTHER;
                    commentsNeeded = true;
            end
            
            if (commentsNeeded)
                comments = input('Comments: ','s');
            end
            disp('?---------------------------------------------------------------------------?');
            disp('?                     Trial Mistake Report Mode ENDED                       ?');
            disp('?---------------------------------------------------------------------------?');
            
        end
        
        function sequenceLog = showCFStrial(this)
            % shows the trial that was prepared
            % start timer to drop shutter:
%             start(timer('StartDelay',this.moverioDelay/1000,...
%                 'TimerFcn',@this.onShutterDropTimerEnded,...
%                 'ExecutionMode','fixedRate'));
            % custom events and their frames (to drop the shutter etc.):
            dropShutterFrameNum = (this.cfsProps.pretrialFixationDuration+...
                this.moverioDelay)/1000*this.cfsProps.fps;
            customEvents = [1,dropShutterFrameNum];
            % start the display and then collect the data:
            
%             sequenceLog =...
%             this.displayTexturesSequence_QueuedResponseSingle(...
%                 this.CurrTrial_leftTextureSeq(),this.CurrTrial_rightTextureSeq(),this.KEYBOARD_DEVICE_NUMBER,customEvents);
            sequenceLog =...
            this.displayTexturesSequence_QueuedResponseSingle(...
                this.CurrTrial_leftTextureSeq(),this.CurrTrial_rightTextureSeq(),this.MOUSE_DEVICE_NUMBER,customEvents);

            % Display trial duration for debugging purposes:
            fprintf('Trial duration was %2.3fs \n',sequenceLog.duration);
            
            % After the trial is over, show a fixation with a blank
            % background and fusion frame again:
            this.showFixationAndFrameBlankBG();
        end
        
        function showFixationAndFrameBlankBG(this)
            this.displayTexturesSequence_NoResponse(...
            [this.transparentFixationTexture,2],[this.transparentFixationTexture,2]);
        end
        
        function onResponseDuringSeq(this,resp)
            this.breakLoopFlag = true;
        end
        
        function onShutterDropTimerEnded(this,timer,varargin)
            stop(timer);
            this.devicesManager.startTrial();
        end
        
        function seq = CurrTrial_leftTextureSeq(this)
            seq = this.currTrialMondrianSeq;
            if (this.domEye == 'r')
                seq = this.currTrialOverlaySeq;
            end
        end
        
        function seq = CurrTrial_rightTextureSeq(this)
            seq = this.currTrialOverlaySeq;
            if (this.domEye == 'r')
                seq = this.currTrialMondrianSeq;
            end
        end
        
        function onCustomEvent(this,eventID)
            this.devicesManager.startTrial();
        end
    end
    
end

