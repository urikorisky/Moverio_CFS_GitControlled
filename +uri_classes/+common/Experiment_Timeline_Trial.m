classdef Experiment_Timeline_Trial < uri_classes.common.Experiment_Timeline
    %EXPERIMENT_TIMELINE_TRIAL An implementation of the class "Timeline" in
    %a shape of a trial
    %   
    
    properties
        code @double; % A code representing the trial - usually a combination of digits which states the levels of the different conditions
        % NOTE: we keep here the names of the conditions and the levels.
        % This seems redundant but as it's super important, we don't want
        % to need to interpret this externally using the code.
        conds_names @cell; % A cell array with the names of the conditions
        level_names @cell; % An array of the names of the levels which were assigned to this trial. The order is the same as in conds_names
        level_nums @double; % A vector, entry i is the level of the i-th condition.
        stimID @double; % A monovalent identifier of the stimulus presented in this trial. This is the case for a simple, one-stimulus trial.
        ID @double; % A number representing the index of this trial in its parent timeline.
    end
    
    methods
        
        function this = Experiment_Timeline_Trial()
            this.createPropsMap({'Trial_ID','Code','Condition_Names','Levels_Names','Levels_Numbers','Stimulus_ID'},...
                {'ID','code','conds_names','level_names','level_nums','stimID'})
        end
        
        function start(this)
            start@uri_classes.common.Experiment_Timeline(this);
            % The rest is to be redefined by subclasses
        end
        
        function infoObj = exportInfo(this)
            infoObj = this.getThisLevelInfo();
        end

        function importInfo(this,trialInfo)
            this.setProps(trialInfo);
        end
        
        function infoObj = getThisLevelInfo(this)
            infoObj = this.getProps();
        end
       
        function [currSteps] = getTimelinePosition(this)
            currSteps = [];
            % assuming no steps inside trial
        end
        
        function names = condsNamesForPrint(this)
            names = this.conds_names;
        end
        
        function readableForm = print(this)
%             readableForm = {'Session','Block','Trial','Code','Ended?'};
            readableForm = [this.code,this.ended,this.level_names];
        end
        
    end
    
end

