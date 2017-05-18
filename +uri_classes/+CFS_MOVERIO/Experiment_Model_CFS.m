classdef Experiment_Model_CFS < uri_classes.common.Experiment_Model
    %EXPERIMENT_MODEL_CFS Summary of this class goes here
    %   Detailed explanation goes here
    

    
    properties
        currentTrial @uri_classes.CFS_MOVERIO.CFS_Timeline_Trial;
        previousTrial @uri_classes.CFS_MOVERIO.CFS_Timeline_Trial;
        upcomingTrials; % A cell array of type @uri_classes.CFS_MOVERIO.CFS_Timeline_Trial
        upcomingTrialsDuringBreak; % A cell array of type @uri_classes.CFS_MOVERIO.CFS_Timeline_Trial, 3 times more trials.
        currentTrialNum @double;
        numTrialsTillBreak @double; % How many trials pass before we initiate a break for the subject to rest
    end
    
    properties (Constant)
        
    end

    
    methods
        
        function this = Experiment_Model_CFS()
            this.DataManager = uri_classes.CFS_MOVERIO.ExperimentDataManager_CFS();
        end
        
        function evListener = getTimelineListener(this,callbackTrialOnsetFunc)
            evListener = this.DataManager.getTimelineListener(callbackTrialOnsetFunc);
        end
        
        function restartPlan(this)
            this.DataManager.restartPlan();
        end

        function logTrialResult(this,trialObj,results)
            this.DataManager.logTrialResult(trialObj,results);
        end
        
        function addMistakeReportToTrial(this,trialObj,reportCode,comment)
            trialRecord = this.DataManager.retreiveTrialRecord(trialObj);
            trialRecord.Comments = comment;
            trialRecord.Mistake = reportCode;
            this.updateTrialLog(trialObj,trialRecord);
        end
        
        function updateTrialLog(this,trialObj,results)
            this.DataManager.updateTrialResult(trialObj,results);
        end
        
        function trialNum = get.currentTrialNum(this)
            trialNum = this.DataManager.currentTrialNum;
        end
        
        function numTrials = get.numTrialsTillBreak(this)
            numTrials = this.DataManager.numTrialsTillBreak;
        end
        
        function trial = get.currentTrial(this)
            trial = this.DataManager.currentTrial;
        end

        function trial = get.previousTrial(this)
            trial = this.DataManager.previousTrial;
        end

        
        function [trials] = get.upcomingTrials(this)
            trials = this.DataManager.upcomingTrials();
        end
        
        function [trials] = get.upcomingTrialsDuringBreak(this)
            trials = this.DataManager.upcomingTrialsDuringBreak();
        end
        
        
    end
    
end

