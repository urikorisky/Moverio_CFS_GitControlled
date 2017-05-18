classdef CFS_Experiment_Plan_Factory < uri_classes.common.Experiment_Plan_Factory_SessBlockTrial
    %CFS_EXPERIMENT_PLAN_FACTORY Creates experiment plans for the CFS
    %study. Can import existing plans.
    %   Detailed explanation goes here
    
    properties
        eachStimRepeats = 0; %how many times should each stimulus repeat. Used for calculating number of needed trials.
        stimuliList;
        numStimuli @double;
        STIMULUS_ID_COND_NAME = 'StimulusID';
        stimIDcondNum @double;
        MAX_SEQUENTIAL_REPEATS_STIM = 3; % HARD CODED! change.
    end
    
    methods
        
        function this = CFS_Experiment_Plan_Factory()
            this = this@uri_classes.common.Experiment_Plan_Factory_SessBlockTrial();
            this.addProps({'Each_Stimulus_Repeats','Stimuli_List','Number_Of_Stimuli'},...
                {'eachStimRepeats','stimuliList','numStimuli'});
        end
        
        function setProps(this,props)
            % in addition to the basic operation, if stimuli repeats is
            % available, replace #numOfTrials with a calculation.
            % Stimuli list is supposed to be received through the props.
            
            % calculate number of trials needed:
            setProps@uri_classes.common.Experiment_Plan_Factory_SessBlockTrial(this,props);
        end

        function addCondition(this,condName,condLevels,condLevelProportions)
            addCondition@uri_classes.common.Experiment_Plan_Factory(this,condName,condLevels,condLevelProportions);
            this.updateNumTrials();
        end
        
        function updateNumTrials(this)
             if (this.eachStimRepeats > 0)
                [~,overallTrials] = this.getCondsLevelsCount([]);
                this.trialsPerBlock = sum(overallTrials)*this.eachStimRepeats;
            end            
        end
        
        function [order,status] = getListOfTrialsLevels(this,numTrials)
            % add a pseudo-condition of stimulus ID for list building:
            this.addCondition(this.STIMULUS_ID_COND_NAME,num2cell([1:this.numStimuli]),[this.stimuliList.repProportions{:}]);
            this.stimIDcondNum = find(strcmp({this.conds(:).name},this.STIMULUS_ID_COND_NAME));
            this.addConstraint(this.stimIDcondNum,this.MAX_SEQUENTIAL_REPEATS_STIM);
            if (this.eachStimRepeats > 0)
                numTrials = this.trialsPerBlock;
            end
            [order,status] = ...
                getListOfTrialsLevels@uri_classes.common.Experiment_Plan_Factory_SessBlockTrial(this,numTrials);
            % and then remove it...
            this.removeCondition(this.stimIDcondNum);
        end
        
        function trial = createTrialWithConds(this,trialCondsLevels)
            % change the levels such that the condition for stimulus ID is
            % omitted. Save it here, but send to the superclass method
            % without it and add it later:
            currTrialStimNum = trialCondsLevels(this.stimIDcondNum);
            trialCondsLevels(this.stimIDcondNum) = [];
            % will it work now?
            trial = createTrialWithConds@uri_classes.common.Experiment_Plan_Factory_SessBlockTrial(this,trialCondsLevels);
            trial.stimID = currTrialStimNum;
            trial.stimName = this.stimuliList.name{[this.stimuliList.ID{:}] == currTrialStimNum};
        end
        % This doesn't even exist:
%         function setCFSexperimentParams(this,params)
%             this.setProps(params);
%             numConds = params.Number_Of_Conditions;
%             for iCond = 1:numConds
%                 this.addCondition(params.(['Condition_' num2str(iCond) '_Name']),...
%                     params.(['Condition_' num2str(iCond) '_Levels']),...
%                     params.(['Condition_' num2str(iCond) '_LevelsProportions']));
%             end
%             
%             numConsts = params.Number_Of_Constraints;
%             for iConst = 1:numConsts
%                 this.addConstraint(params.(['Constraint_' num2str(iConst) '_Conditions']),...
%                     params.(['Constraint_' num2str(iConst) '_Max_Repetitions']));
%             end
%         end
        
        function classPointer = TIMELINE_CLASS(this)
            classPointer = @uri_classes.CFS_MOVERIO.CFS_Experiment_Timeline;
        end
        
        function trial = getEmptyTrial(this)
            trial = uri_classes.CFS_MOVERIO.CFS_Timeline_Trial();
        end
        
        
    end
    
    
    
end

