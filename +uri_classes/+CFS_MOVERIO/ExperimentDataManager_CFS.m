classdef ExperimentDataManager_CFS < uri_classes.common.ExperimentDataManager
    %CFS_EXPERIMENTDATAMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        currentTrial; %The current trial of the experiment plan
        previousTrial; %The current trial of the experiment plan
        upcomingTrials; %A cell array of N upcoming trials after the current one
        upcomingTrialsDuringBreak %A cell array of N*3 upcoming trials after the current one
        currentTrialNum @double; % How many trials passed since exp started
        numTrialsTillBreak @double; % How many trials pass before we initiate a break for the subject to rest
    end
    
    methods
        
        function this = ExperimentDataManager_CFS()
            this = this@uri_classes.common.ExperimentDataManager();
            this.experimentParameters = uri_classes.CFS_MOVERIO.ExperimentParameters_CFS();
            this.subjectData = uri_classes.CFS_MOVERIO.SubjectData_CFS();
            this.planFactory = uri_classes.CFS_MOVERIO.CFS_Experiment_Plan_Factory();
            this.logManager = uri_classes.CFS_MOVERIO.CFS_Experiment_LogsManager();
            this.logManager.expStartTime = this.startClock;
            this.logManager.createLogDir('logs',this.experimentParameters.logsFolder);
            
        end
        
        function setSubjID(this,subjID)
            setSubjID@uri_classes.common.ExperimentDataManager(this,subjID)
            this.logManager.createNewRunLog(subjID);
        end
        
        function importParametersNamesAndValuesFromFile(this,fileName)
            importParametersNamesAndValuesFromFile@uri_classes.common.ExperimentDataManager(this,fileName);
            % Set the conditions into the plan factory:
            [conds,levels,proportions] = this.experimentParameters.listCondsAndLevels();
            for iCond = 1:numel(conds)
                this.planFactory.addCondition(conds{iCond},levels{iCond},proportions{iCond});
            end
            % Set the constraints into the plan factory:
            [conds,reps] = this.experimentParameters.listConstraintsAndReps();
            for iConst = 1:numel(conds)
                this.planFactory.addConstraint(conds{iConst},reps{iConst});
            end
            
            % Set the per-trial log record fields name:
            this.logManager.setPerTrialRecordFieldNames(this.experimentParameters.trialDataLogFields);
        end
        
        
        function evListener = getTimelineListener(this,callbackTrialOnsetFunc)
            evListener = this.experimentPlan.getTimelineListener(callbackTrialOnsetFunc);
        end
        
        function restartPlan(this)
            this.experimentPlan.restartPlan();
        end
        
        function logTrialResult(this,trialObj,results)
            this.logManager.logTrialResult(this.experimentPlan,trialObj,results);
        end
        
        function trialRecord = retreiveTrialRecord(this,trialObj)
            trialRecord = this.logManager.retreiveTrialRecord(trialObj);
        end
        
        function updateTrialResult(this,trialObj,results)
            this.logManager.updateTrialRecord_findRecord(trialObj,results);
        end
        
        function trial = get.currentTrial(this)
            trial = this.experimentPlan.currentTrial;
        end
        
        function trial = get.previousTrial(this)
            trial = this.experimentPlan.previousTrial;
        end
        
        function trials = get.upcomingTrials(this)
            % Get the number of upcoming trials to get:
            numTrialsToGet = this.experimentParameters.upcomingTrialsToShow;
            trials = this.experimentPlan.getNextTrials(numTrialsToGet);
        end
        
        function trials = get.upcomingTrialsDuringBreak(this)
            % Get the number of upcoming trials to get:
            numTrialsToGet = this.experimentParameters.upcomingTrialsToShow*3;
            trials = this.experimentPlan.getNextTrials(numTrialsToGet);
        end
        
        function trialNum = get.currentTrialNum(this)
            trialNum = this.experimentPlan.getTimelineSummedPosition();
        end
        
        function numTrials = get.numTrialsTillBreak(this)
            numTrials = this.experimentParameters.trialsTillBreak;
        end
        
        
        
    end
    
end

