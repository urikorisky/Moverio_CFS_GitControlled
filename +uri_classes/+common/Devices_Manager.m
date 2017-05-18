classdef Devices_Manager < handle
    %DEVICES_MANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        devicesList = {};
    end
    
    methods
        function newDevice = addDevice(this,deviceClass)
            newDevice = deviceClass();
            this.devicesList{end+1} = newDevice;
        end
    end
    
end

