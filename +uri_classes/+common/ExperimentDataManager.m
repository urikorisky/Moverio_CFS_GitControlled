classdef ExperimentDataManager < handle
    properties
        experimentParameters @uri_classes.common.ExperimentParameters;
        subjectData @uri_classes.common.ExperimentParameters;
        logManager @uri_classes.common.LogsManager;
        planFactory @uri_classes.common.Experiment_Plan_Factory;
        experimentPlan @uri_classes.common.Experiment_Timeline;
        startClock;
    end
    
    methods (Access = public)
        function this = ExperimentDataManager(varargin)
            this.startClock = clock;
            this.experimentParameters = uri_classes.common.ExperimentParameters();
            this.subjectData = uri_classes.common.ExperimentParameters();
            this.planFactory = uri_classes.common.Experiment_Plan_Factory();
            this.logManager = uri_classes.common.LogsManager();
            this.logManager.expStartTime = this.startClock;
%             this.logManager.createLogDir('logs',this.experimentParameters.logsFolder);
        end
        
        function setSubjID(this,subjID)
            this.experimentParameters.subjectID = subjID;
            this.subjectData.subjectID = subjID;
        end
        
        function id = getSubjID(this)
            id = this.experimentParameters.subjectID;
        end
        
        function [subjProps,subjPropsMeta] = getSubjInfo(this)
            [subjProps,subjPropsMeta] = this.subjectData.getProps();
        end
        
        function setSubjInfo(this,props)
            this.subjectData.setProps(props);
        end
        
        function params = exportParameters(this)
            params = this.experimentParameters.getProps;
        end
        
        function writeLog(this)
        end
        
        function importParametersNamesAndValuesFromFile(this,fileName)
            this.experimentParameters.setPropsNamesAndValuesFromFile(fileName);
            this.subjectData.setPropsNamesAndValuesFromFile(fileName);
            this.planFactory.setProps(this.experimentParameters.getProps);

        end
        
        function importParametersValuesFromFile(this,fileName)
            % TODO. Happens when the needed variables already exist in
            % experimentParameters, and it's only their values that need to
            % be changed.
        end       
        
        function showParametersGUI(this)
            % TODO
        end
        
        
        function [subjExpTimelineFiles,status] = retrieveSubjectTimelineFiles(this,subjID)
            [subjExpTimelineFiles, status]= this.logManager.findSubjExpTimeline(subjID);
        end
        
        function [timelineObj] = createSubjectExperimentPlan(this)
            timelineObj = this.planFactory.produceExperimentTimeline();
        end
        
        function saveExperimentPlan(this)
            [mat_FN,xlsx_FN] = this.logManager.createExpPlanFileName(this.experimentParameters.subjectID);
            expPlan = this.experimentPlan;
            save([this.logManager.defaultLogDir mat_FN],'expPlan');
            % Also save experiment plan as an XLSX file:
            xlswrite([this.logManager.defaultLogDir xlsx_FN],expPlan.print());
        end
        
        function loadExperimentPlan(this,planFN)
            load(planFN); % assume the variable is "expPlan"!
            this.experimentPlan = expPlan;
        end
        
        function saveAllData(this)
            % Save all logs as files:
%             this.logManager.flushAllLogsToFiles();
            % Should save all parameters for file as well
            % Should save the whole instance of this object too! to a specific folder.
            this.saveObjectAsMATfile(this);
        end
        
        function saveObjectAsMATfile(this,object)
            outDir = this.logManager.defaultLogDir;
            ExperimentObject = object;
            ObjectClass = class(ExperimentBaseObject);
            if (outDir)
                save ([outDir '/Experiment_Data_Manager_obj.mat'],'ExperimentObject','ObjectClass');
            else
                warning('Could not save Experiment object as a MAT file because no default directory was provided by its LogManager!');
            end
        end

    end
end