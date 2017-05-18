classdef CFS_View_Devices_Manager < uri_classes.common.Devices_Manager
    %CFS_VIEW_DEVICES_MANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        theater @uri_classes.CFS_MOVERIO.CFS_Theater_Device;
        TIME_TO_REACTIVATE_MAGNET_MS = 200;
    end
    
    methods
        
        function this = CFS_View_Devices_Manager()
            this.theater = this.addDevice(@uri_classes.CFS_MOVERIO.CFS_Theater_Device);
            % HARD CODED FOR DEBUG:
            this.theater.init('c100');
            this.reactivateMagnet();
            % /DEBUG
        end
        
        function [openShutterTime] = startTrial(this)
            openShutterTime = this.theater.openShutter();
%             wanted_reactivateMagnetTime = openShutterTime+this.TIME_TO_REACTIVATE_MAGNET_MS;
            start(timer('StartDelay',this.TIME_TO_REACTIVATE_MAGNET_MS/1000,...
                'TimerFcn',@this.reactivateMagnet));
        end
        
        function [timeMagnetReactivated] = reactivateMagnet(this,varargin)
            timeMagnetReactivated = this.theater.reactivateMagnet();
        end
        
        function dropShutter(this)
            this.theater.openShutter();
        end
        
    end
    
end

