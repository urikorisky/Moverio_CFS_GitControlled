classdef Experiment_Presenter_CFS < uri_classes.common.Experiment_Presenter
    %EXPERIMENT_PRESENTER_CFS The "presenter" part of the MPV design used
    %for the Moverio first CFS experiment (methodological testing of
    %real-life CFSing using semitransparent display).
    %   Detailed explanation goes here
    
    events
        SUBJ_PLAN_READY
    end
    
    properties
        currentTrial @uri_classes.CFS_MOVERIO.CFS_Timeline_Trial;
        previousTrial @uri_classes.CFS_MOVERIO.CFS_Timeline_Trial;
        timelineEventListener; % a listener to timeline events it gets from the model
    end
    
    methods
        
        function this = Experiment_Presenter_CFS()
            this.View = uri_classes.CFS_MOVERIO.Experiment_View_CFS();
            this.Model = uri_classes.CFS_MOVERIO.Experiment_Model_CFS();
%             addlistener(this,'SUBJ_PLAN_READY',@this.onSubjPlanReady);
        end
        
        function initExperiment(this)
            % 0) Ask for experiment parameters file. This can include a
            % default experiment plan but doesn't have to.
            [FileName,PathName] = uigetfile('./Stim/CFS_defaultParams.xlsx',this.Model.GET_EXP_PARAMS_MSG);
            this.Model.setExperimentParametersFromFile([PathName FileName]);
            this.View.setProps(this.Model.getExperimentParameters);
            % 1) Ask for subject ID
            subjPlanExists = this.Model.setCurrentSubjID(this.getCmdWindowInput(this.Model.GET_SUBJ_ID_MSG));
            
            % If test subject, set debug level accordingly:
            if (this.Model.subjID == '0')
                this.debugLevel = uri_classes.CFS_MOVERIO.CFS_MOVERIO_DebugLevels.TEST_SUBJECT;
            end
            
            % Quick fix for now about the debugging levels, will be more
            % profound later on:
            if (subjPlanExists &&(~this.debugLevel))
                this.onSubjPlanExists();
            else
                % create a new plan
                this.Model.createSubjectPlan();
                this.onSubjPlanReady();
            end
        end
        
        function onSubjPlanExists(this)
            % Subject plan exists. Let user decide if to continue with the
            % selected plan, or create a new one from scratch:
            msg = this.Model.USE_EXISTING_SUBJ_PLAN_QUES_MSG;
            planFiles = this.Model.retrieveSubjectPlanFiles(this.Model.subjID);
            msg = strrep(strrep(msg,'<subjID>',this.Model.subjID),'<fn>',planFiles{1});
            switch (str2double(this.getCmdWindowInput(msg)))
                case 1
                    % continue with the existing plan
                    this.Model.useExistingPlan(planFiles{1});
                case 2
                    % create a new plan
                    this.Model.createSubjectPlan();
                otherwise
            end
            this.onSubjPlanReady();
        end
        
        function onSubjPlanReady(this)
            this.collectSubjInfo();
            this.startExpWithSubjData();
        end
        
        function collectSubjInfo(this)
            if (this.debugLevel)
                this.View.domEye = 'r';
                % Quick fix, should be more profound later
                return;
            end
            [subjInfo,subjInfoMeta] = this.Model.getSubjInfo();
            propsToCollect = fields(subjInfo);
            for iProp = 1:numel(propsToCollect)
                subjInfo.(propsToCollect{iProp}) = ...
                    this.getCmdWindowInput([subjInfoMeta.(propsToCollect{iProp}).GUI_input_text ': ']...
                    );
            end
            this.Model.setSubjInfo(subjInfo);
            this.View.domEye = subjInfo.Subject_Dominant_Eye;
        end
        
        function startExpWithSubjData(this)
            % print list of first trials, to allow experimenter to prepare
            % while everything is setting up:
            this.showNextTrialsDetails();
            
            % Init View GUI
            PTB_interface_params = uri_classes.common.PTB_Interface_Params;
            PTB_interface_params.debugLevel = uri_classes.common.PTB_Interface_Params.DEBUG_LEVEL_HIGH;
            this.View.initGUI(PTB_interface_params);
            
            % show next trials details again in case there was too much
            % text desplayed during graphics init:
            this.showNextTrialsDetails();
            % run fusion calibration:
            this.initFusion();
            
            % TODO: training!!!
            
            % Show a fixation:
            this.View.showFixationAndFrameBlankBG();
            
            % 4) start the timeline: start actual experiment
            
            this.showTimelineFromBeginning();
%             start(timer('StartDelay',0.1,'TimerFcn',@this.showTimelineDelayTest))
        end
        
        function initFusion(this)
            % Run a fusion calibration and prepare textures in the View
            if (~this.debugLevel)
                this.View.runFusionCalibration(60);
            end
            this.View.setCFSproperties(this.Model.getExperimentParameters());
            this.View.prepareAssets();
        end
        
        function showTimelineFromBeginning(this)
            delete(this.timelineEventListener)
            this.timelineEventListener = this.Model.getTimelineListener(@this.onTimelineEvent);
            this.Model.restartPlan();
        end
        
        function onTimelineEvent(this,src,evtData)
            switch(evtData.name)
                case this.currentTrial.TRIAL_STARTED_EVENT_NAME
                    % ver06: check for necessity of break
                    if (mod(this.Model.currentTrialNum,this.Model.numTrialsTillBreak)==0)
                        % break needed
                        this.showBreakBeforeTrial();
                    else
                        % no break needed now
                        start(timer('StartDelay',0.1,'TimerFcn',@this.onTrialOnset))
                    end
                otherwise
            end
        end
        
        function onTrialOnset(this,varargin)
%             disp(varargin{1});
            % A trial has been received from the model. Run this trial in
            % the viewer, given its properties.
            
% % %             % First, delete the timer that called this function, if such
% % %             % exists:
% % %             if (nargin>0)
% % %                 try
% % %                     stop(varargin{1});
% % %                     delete(varargin{1});
% % %                 catch e
% % %                     disp('Could not delete timer calling onTrialOnset!');
% % %                 end
% % %             end
            
            this.View.prepareCFStrial_defaultProps();
            
            this.showNextTrialsDetails();
%             this.View.showCmdWindowTrialProps(this.currentTrial,'short');
            [timePendingEnd,keyPressed] = this.View.pendExperimenterTrialStart();
            if (keyPressed(uri_classes.common.PTB_KbConsts.ESC))
                % ESC was pressed, which means the experimenter needs to
                % fix a mistake made in the previous trial. End this
                % routine, enter report mode, and call this function again
                % once the report is done. Do this in an asynchronuous
                % fashion:
                start(timer('StartDelay',0.01,...
                    'TimerFcn',@this.onExperimenterRequestMistakeReport,...
                    'ErrorFcn',@this.onTimerErr))
%                 this.onExperimenterRequestMistakeReport();
                return;
            end
            trialLog = this.View.showCFStrial();
            % once the trial is done, save the data:
            this.Model.logTrialResult(this.currentTrial,trialLog);
            % and tell the trial to finish, so the next one can be
            % displayed. Whether or not the next one automatically starts
            % depends on the timeline's definitions (well, not currently,
            % but in the future. right now it's automatic).
            this.currentTrial.finish();
        end
        
        function showNextTrialsDetails(this,varargin)
            upcomingTrials = this.Model.upcomingTrials;
            this.View.showThisTrialPropsAndUpcoming([{this.currentTrial} upcomingTrials]);
        end
        
        function onExperimenterRequestMistakeReport(this,varargin)
            this.pendReportMistakeInPreviousTrial();
        end
        
        function pendReportMistakeInPreviousTrial(this)
            [reportCode, comment] = this.View.getMistakeReportForTrial(this.previousTrial);
            this.Model.addMistakeReportToTrial(this.previousTrial,reportCode,comment);
            % now go back to running the trial we were at:
            start(timer('StartDelay',0.1,'TimerFcn',@this.onTrialOnset))
        end
        
        function showBreakBeforeTrial(this)
            this.View.showBreakMessage([{this.currentTrial} this.Model.upcomingTrialsDuringBreak]);
            % Now get back to running the trial we were at:
            start(timer('StartDelay',0.1,'TimerFcn',@this.onTrialOnset))
        end
        
        function trial = get.currentTrial(this)
            trial = this.Model.currentTrial();
        end
        
        function trial = get.previousTrial(this)
            trial = this.Model.previousTrial();
        end
        
        function onTimerErr(this,varargin)
            disp('errr!');
            disp(this);
            disp(varargin{1});
            disp(varargin{2});
        end
        
    end
    
end

