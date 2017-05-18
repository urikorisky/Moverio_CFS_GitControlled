classdef A < handle
    %A Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        child @A;
    end
    
    events
        evt;
    end
    
    methods
        function sendEvt(this)
            notify(this,'evt');
        end
        
        function addCh(this)
            this.child = A();
            addlistener(this.child,'evt',@this.onEvt);
            disp('hi');
        end
        
        function onEvt(this,source,evt)
            disp('got it!');
        end
    end
    
end

