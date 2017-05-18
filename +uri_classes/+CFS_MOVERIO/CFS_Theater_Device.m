classdef CFS_Theater_Device < uri_classes.common.LPT_Device
    %CFS_THEATER_DEVICE For the device built by Moshe Zer
    %   Detailed explanation goes here
    
    properties
        OPEN_SHUTTER_CODE = 0;
        REACTIVATE_MAGNET_CODE = 1;
    end
    
    methods
        function timeSentCommand = openShutter(this)
            timeSentCommand = this.sendSignal(this.OPEN_SHUTTER_CODE);
        end
        
        function timeSentCommand = reactivateMagnet(this)
            timeSentCommand = this.sendSignal(this.REACTIVATE_MAGNET_CODE);
        end
    end
    
end

