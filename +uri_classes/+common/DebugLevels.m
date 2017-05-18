classdef DebugLevels
    %DEBUGLEVELS Is a set of constants signifying different levels of
    %debugging of an experiment.
    %   Detailed explanation goes here
    
    properties (Constant)
        NO_DEBUG = false; % Default value, run experiment as would be presented to a subject.
        DEBUG_TEST_SUBJ = 1; % Use a test subject. Default values for suvh subject can be set.
        DEBUG_STEP_BY_STEP = 2; % Pace experiment manually, to notice if everything is rendered and presented correctly.
        
    end
    
    methods
    end
    
end

