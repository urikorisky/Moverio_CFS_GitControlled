classdef Test_Trial < uri_classes.common.Experiment_Timeline
    %TEST_TRIAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function start(this)
            disp ('This is a trial!');
            pause();
            this.endTimeline();
        end
        
    end
    
end

