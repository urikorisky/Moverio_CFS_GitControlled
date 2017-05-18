classdef Experiment_Timeline_SBT_Base < uri_classes.common.Experiment_Timeline
    %EXPERIMENT_TIMELINE_SBT_BASE The base level of an experiment timeline
    %when realized using a Session-Block-Trial architecture
    %   
    
    properties
        currentTrial @uri_classes.common.Experiment_Timeline;
        previousTrial @uri_classes.common.Experiment_Timeline;
    end
    
    methods
        
        function addSession_ByObject(this,session)
            this.stepsList{end+1} = session;
        end
        
        function addSession_ByInfo(this,sessInfo)
            newSess = uri_classes.common.Experiment_Timeline_Session;
            newSess.importInfo(sessInfo);
            this.stepsList{end+1} = newSess;
        end
        
        function start(this)
            start@uri_classes.common.Experiment_Timeline(this);
            % should start running the sessions from the beginning:
            this.nextStep();
        end
        
        function infoObj = exportInfo(this)
            infoObj.props = this.getProps();
            sessionsInfo = cell(numel(this.stepsList),1);
            for iSess = 1:numel(sessionsInfo)
                sessionsInfo{iSess} = this.stepsList{iSess}.exportInfo();
            end
            infoObj.sessions=sessionsInfo;
        end
        
        function createStepsList(this,sessionsInfos)
            for iSess = 1:numel(sessionsInfos)
                this.addSession_ByInfo(sessionsInfos{iSess});
            end
        end
        
        function importInfo(this,timelineInfo)
            this.setProps(timelineInfo.props);
            this.createStepsList(timelineInfo.sessions);
        end
        
        function readableForm = print(this)
            readableForm = this.getReadableFormHeader();
            listOfConds = this.stepsList{1}.blocks{1}.trials{1}.condsNamesForPrint;
            readableForm = [readableForm listOfConds];
            for iSess = 1:numel(this.stepsList)
                sessReadableForm = this.stepsList{iSess}.print;
                readableForm(end+1:end+size(sessReadableForm,1),:) = ...
                    [num2cell(repmat(iSess,size(sessReadableForm,1),1)),sessReadableForm];
            end
        end
        
        function headerCell = getReadableFormHeader(this)
            headerCell = {'Session','Block','Trial','Code','Ended?'};
        end
        
        function [hierarchy, currSteps] = getTimelinePosition(this)
            currSteps = [this.currentStepIterator this.currentStep.getTimelinePosition];
            hierarchy = {'Session','Block','Trial'};
        end

        function trials = getNextTrials(this,numTrialsToGet)
            trials = {};
            for iLag = 1:numTrialsToGet
                step = this.currentStep.pointerToNextStep(iLag);
                if (~isempty(step))
                    trials{iLag} = step;
                end
            end
        end
        
        function trial = get.currentTrial(this)
            % assuming only three levels, as per this architecture
            trial = this.currentStep.currentStep.currentStep;
        end
        
        function trial = get.previousTrial(this)
            trial = this.currentStep.pointerToNextStep(-1);
        end
        
    end
    
end

