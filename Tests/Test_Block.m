classdef Test_Block < Test_ExperimentTimeline
    %TEST_TRIAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function insertStep(this,stepInfo)
            % Step info shouldn't be specified, this is experiment-specific.
            % If the step is in itself a timeline (session, block etc.) - the info includes all that is needed
            % to create its list as well.
            newStep = Test_Trial();
            this.stepsList{end+1} = newStep;
            newStep.insertStep(stepInfo);
        end
        
    end
    
end

