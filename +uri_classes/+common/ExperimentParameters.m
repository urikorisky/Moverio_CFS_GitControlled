classdef ExperimentParameters < uri_classes.common.PropertiesMappedHandle_ExtCfg
    properties
        mainImportFolder @char
        mainOutputFolder @char
        parametersFolder @char
        logsFolder @char
        subjectID; % don't limit type of subject ID
    end
    
    methods
        function this = ExperimentParameters(varargin)
            if (numel(varargin)==0)
                this.setDefaultValues();
            end
        end
        
        function setDefaultValues(this)
            % set default values:
            cf = [strrep(pwd,'\','/') '/'];
            this.mainImportFolder = cf;
            this.mainOutputFolder = cf;
            this.parametersFolder = [this.mainImportFolder 'parameters/'] ;
            this.logsFolder = [this.mainOutputFolder 'logs/'];
        end
        
        function setPropsNamesAndValuesFromFile(this,fn)
            % Abstract function. Should read an XLSX file (or another type,
            % doesn't matter), and call superclass's
            % "setPropsNamesAndVariablesFromList" function with the proper
            % names, types and values of the properties. Since these could
            % be realized in different manners, I leave it free here.
        end
        
%         function setPropsFromFile(this,fn)
%             % Each subclass should define its own methods of extracting the data from the input file!
% %             [~,~,xlsData] = xlsread(fn);
% %             ep.parseXLSdataInput(xlsData)
%         end
        
    end
end