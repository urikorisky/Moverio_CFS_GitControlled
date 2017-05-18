classdef CFS_Timeline_Trial < uri_classes.common.Experiment_Timeline_Trial
    %CFS_TIMELINE_TRIAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        TRIAL_STARTED_EVENT_NAME = 'trialStarted';
        stimName @char; % Name of the stimulus.
    end
    
    methods
        
        function this = CFS_Timeline_Trial()
            this = this@uri_classes.common.Experiment_Timeline_Trial;
            this.mapSingleProp('Stimulus_Name','stimName');
        end
        
        function start(this)
            start@uri_classes.common.Experiment_Timeline_Trial(this);
            notify(this,'TIMELINE_EVENT',...
                uri_classes.common.Timeline_EventData(this.TRIAL_STARTED_EVENT_NAME));
        end
        
        function finish(this)
            % See what else needs to be done!
            this.endTimeline();
        end
        
        function nextStep(this)
            % Trials here have no steps! overriding superclass method
        end
        
        function names = condsNamesForPrint(this)
            names = condsNamesForPrint@uri_classes.common.Experiment_Timeline_Trial(this);
            names{end+1} = 'StimulusID';
            names{end+1} = 'StimulusName';
        end
        
        function readableForm = print(this)
%             readableForm = {'Session','Block','Trial','Code','Ended?'};
            readableForm = print@uri_classes.common.Experiment_Timeline_Trial(this);
            readableForm{end+1} = this.stimID;
            readableForm{end+1} = this.stimName;
        end
    end
    
end

