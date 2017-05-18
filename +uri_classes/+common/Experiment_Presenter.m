classdef Experiment_Presenter < handle
    %EXPERIMENT_PRESENTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Model @uri_classes.common.Experiment_Model;
        View @uri_classes.common.Experiment_View;
        Devices @uri_classes.common.Devices_Manager; % additional input\output devices. May not be used.
        
        debugLevel; % Takes its values from @uri_classes.common.DebugLevels;
    end
    
    methods
        
        function this = Experiment_Presenter()
            this.View = uri_classes.common.Experiment_View();
            this.Model = uri_classes.common.Experiment_Model();
            this.debugLevel = uri_classes.common.DebugLevels.NO_DEBUG;
        end

        function initGUI(this)
            this.View.initGUI();
        end
        
        function resp = getCmdWindowInput(this,quesText)
            % This function calls for a command-window input prompt, and
            % returns the input given by the user
            % quesText (string) - the text accompanying the input
            % requirement presented in the command window
            resp = input(quesText,'s');
        end
        
        
    end
    
end

