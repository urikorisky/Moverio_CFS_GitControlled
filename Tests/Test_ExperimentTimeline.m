classdef Test_ExperimentTimeline < uri_classes.common.Experiment_Timeline
    %TEST_EXPERIMENTTIMELINE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function insertStep(this,stepInfo)
            % Step info shouldn't be specified, this is experiment-specific.
            % If the step is in itself a timeline (session, block etc.) - the info includes all that is needed
            % to create its list as well.
            newStep = Test_Block();
            this.stepsList{end+1} = newStep;
            newStep.insertStep(stepInfo);
        end
      
        function start(this)
            start@uri_classes.common.Experiment_Timeline(this);
            this.nextStep();
        end
        
        function nextStep(this)
%             disp(this.currentStepIterator);
            nextStep@uri_classes.common.Experiment_Timeline(this);
            if (this.ended)
                return
            end
            this.currentStep.start();
        end

        
        
    end
    
end

