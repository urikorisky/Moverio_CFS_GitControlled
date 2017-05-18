classdef Experiment_Timeline < uri_classes.common.PropertiesMappedHandle
    %EXPERIMENT_TIMELINE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        currentStep @uri_classes.common.Experiment_Timeline;
        stepsList = {}; % To show that it's a cell array
        ended = false; % Did the timeline end?
        started = false; % Did the timeline start already?
        currentStepIterator = 1;
        stepGenericListener @event.listener;
    end
    
    properties (Access = protected)
        stepEndedListener @event.listener;
    end
    
    events
        ListEnded;
        TIMELINE_EVENT;
    end
    
    methods
        
        function insertStep(this,stepInfo)
            % Step info shouldn't be specified, this is experiment-specific.
            % If the step is in itself a timeline (session, block etc.) - the info includes all that is needed
            % to create its list as well.
        end
        
        function createStepsList(this,stepInfoList)
            % iterate steps infos to create list
        end
        
        function start(this)
            this.ended = false;
            this.started = true;
            this.currentStepIterator = 1;
            % start playing the steps list
        end
        
        function resume(this)
            % play the current step, without re-starting the timeline
            this.ended = false;
            this.started = true;
            % insert here command to resume() the current step
        end
        
        function nextStep(this,varargin)
            % remove listener from previous step
            delete (this.stepEndedListener);
            delete (this.stepGenericListener);
            
            % iterate to next step
%             this.currentStep = this.stepsList{this.currentStepIterator};
%           (No need - this is done in the getter function itself)
            if (~this.currentStep.ended)
                % add listener to current step
                this.stepEndedListener = addlistener(this.currentStep,'ListEnded',@this.onStepEnded);
                this.stepGenericListener = addlistener(this.currentStep,'TIMELINE_EVENT',@this.onTimelineEvent);
                if (this.currentStep.started)
                    this.currentStep.nextStep();
                else
                    this.currentStep.start();
                end
                return;
            end
            
            this.currentStepIterator = this.currentStepIterator + 1;
            if (this.currentStepIterator > numel(this.stepsList))
                this.endTimeline();
                return;
            end
            
            this.stepEndedListener = addlistener(this.currentStep,'ListEnded',@this.onStepEnded);
            this.stepGenericListener = addlistener(this.currentStep,'TIMELINE_EVENT',@this.onTimelineEvent);
            this.currentStep.start();
            
        end
        
        function step = pointerToNextStep(this,lag)
            % THIS FUNCTION WILL BREAK!
            % It will only behave well when there's only 1 level with more
            % than 1 step. For example 1 session, with 1 block, and 30
            % trials. Add another block, and it will break down because of
            % the very line that advances the counter:
            % (nextStepIdx = this.currentStepIterator + lag;)
            
            if (isempty(lag))
                lag = 1;
            end
            if (isempty(this.getTimelinePosition))
                % You're at the deepest depth in the hierarchy. No levels
                % within this step:
                step = [];
                return;
            end
            % You're not at the deepest level. What is the current step in
            % this level's list pointing to as its next step? It could be
            % that it also has more levels and we need to advance inside
            % its list:
            step = this.currentStep.pointerToNextStep(lag);
            if (isempty(step))
                % The current step has no successor within its list.
                % Therefore, the next step in this level's list is the 
                % step we need to return:
                nextStepIdx = this.currentStepIterator + lag;
                if ((nextStepIdx > numel(this.stepsList)) || (nextStepIdx < 1))
                    % If this level's list is over, we signal that to the
                    % level above by returning an empty step.
                    step = [];
                else
                    % Another step exists in the list of this level. Go
                    % down one level and take the current step, which
                    % *should be* the first one:
                    step = this.stepsList{nextStepIdx}.currentStep;
                    if (isempty(step))
                        % If we've reached the deepest depth, and the next
                        % step has no levels, then it is itself the next step:
                        step = this.stepsList{nextStepIdx};
                    end
                end
            end
            
        end
        
        function onTimelineEvent(this,source,evtData)
%             disp([class(this) ' got event from ' class(source)]);
            notify(this,'TIMELINE_EVENT',evtData);
        end
        
        function onStepEnded(this,source,evt)
%             disp('onStepEnded!');
            % To emulate asynchronuous execution, we use a timer object and
            % let this function terminate before the callback executes:
            start(timer('StartDelay',0.01,'TimerFcn',@this.nextStep))
%             this.nextStep();
        end
        
        function gotoStep(this,stepRec)
            % A recursive function - go to the first index in the vector
            % "stepRec", and deliver the rest of this vector to the step
            % itself, to jump to the appropriate location within it.
            if (isempty(stepRec))
                return;
            end
            requiredStep = stepRec(1);
            if ((requiredStep>numel(this.stepsList) || requiredStep<1))
                error (['Trying to access a step that does not exist in ' class(this)]);
            end
            this.currentStepIterator = stepRec(1);
            % iterate to next step
%             this.currentStep = this.stepsList{this.currentStepIterator};
%             (No need - this is done in the getter function itself)
            % add listener to current step
            this.stepEndedListener = addlistener(this.currentStep,'ListEnded',@this.onStepEnded);
            if (numel(stepRec)>1)
                this.currentStep.gotoStep(stepRec(2:end));
            end
        end
        
        function endTimeline(this)
            this.ended = true;
            notify(this,'ListEnded');
        end
        
        function currStep = get.currentStep(this)
            if (~isempty(this.stepsList))
                currStep = this.stepsList{this.currentStepIterator};
            else
                currStep = [];
            end
        end
        
        function infoObj = exportInfo(this)
            % A recursive function which exports the whole timeline as an
            % object which is detailed enough for it to be recreated
            % identically, including step numbers etc.
            % Should be realized by the subclass, depending on the
            % experiment's architecture. Pseudocode:
%             for iStep = 1:numel(this.stepsList)
%                 infoObj = infoObj+this.stepsList{iStep}.exportInfo;
%             end  
%             infoObj = this.getThisLevelInfo() + infoObj;
        end
        
        function infoObj = getThisLevelInfo(this)

        end
        
        function importInfo(this,importObj)
            % Import info about this level and all its steps, then create
            % steps iteratively
        end
        
        function currSteps = getTimelinePosition(this)
            currSteps = [this.currentStepIterator this.currentStep.getTimelinePosition];
        end
        
        function currLeafStep = getTimelineSummedPosition(this)
            if(isempty(this.stepsList))
                currLeafStep = 1;
                return;
            end
            currLeafStep = 0;
            for iStep = 1:min(this.currentStepIterator,numel(this.stepsList))
                currLeafStep = currLeafStep+this.stepsList{iStep}.getTimelineSummedPosition();
            end
        end
        
    end
    
end

