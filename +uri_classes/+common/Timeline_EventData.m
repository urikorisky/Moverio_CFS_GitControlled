classdef Timeline_EventData < event.EventData
    %TIMELINE_EVENTDATA A class describing eventdata for a timeline.
    % This is class is necassery because MATLAB doesn't have propogation of
    % events, so each object can only listen to events of its properties,
    % and the events the properties send have to be well-defined.
    % This class allows "bubbling" upwards of events, while the name of the
    % event stays the same, but the "name" property allows recognition of
    % where in the hierarchy of the timeline this event came from and what
    % does it mean.
    
    properties
        name @char; % This
    end
    
    methods
        
        function this = Timeline_EventData(name,varargin)
            this.name = name;
        end
        
    end
    
end

