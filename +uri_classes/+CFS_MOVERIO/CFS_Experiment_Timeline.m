classdef CFS_Experiment_Timeline < uri_classes.common.Experiment_Timeline_SBT_Base
    %CFS_EXPERIMENT_TIMELINE 
    %   
    
 
    properties
    end
    
    methods
        function evListener = getTimelineListener(this,callbackTrialOnsetFunc)
            evListener = addlistener(this,'TIMELINE_EVENT',callbackTrialOnsetFunc);
        end
        
        function restartPlan(this)
            this.start();
        end
    end
    
end

