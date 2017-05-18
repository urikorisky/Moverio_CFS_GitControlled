classdef LPT_Device < handle
    %LPT_DEVICE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ioObj;
        port @double;
    end
    
    methods
        
        function this = LPT_Device()
            try
                testObj = io64();
            catch e
                error('io64() not found! include io64.mexw64 in MATLAB''s search path.');
            end
            clear testObj
        end
        
        function status = init(this,ioPort)
            try
                this.ioObj = io64();
                status = io64(this.ioObj);
                this.port = hex2dec(ioPort);
                io64(this.ioObj,this.port,0);
            catch e
                fprintf ('ERROR!!!\nCouldn''t init io64 to port %s\n',ioPort);
            end
        end
        
        function [timeLetter,timeReset] = sendLetter(this,letter)
            % send an integer and immediately reset to 0
            % letter is an integer between 0-255
            timeLetter = this.sendSignal(letter);
            timeReset = this.sendSignal(0);
        end
        
        function [timeSent] = sendSignal(this,signal)
            % Send an integer without resetting right after
            % signal is an integer between 0-255
            io64(this.ioObj,this.port,signal);
            timeSent = clock;
            disp(['sent ' num2str(signal)]);
        end
        
    end
    
end

