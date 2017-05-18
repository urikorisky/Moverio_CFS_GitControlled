classdef Experiment_Model < handle
    %EXPERIMENT_MODEL Summary of this class goes here
    %   Detailed explanation goes here
  
    events
        SUBJ_PLAN_EXISTS;
    end
    
    properties (Constant)
        GET_SUBJ_ID_MSG = 'Please insert subject ID (0 for test): ';
        NO_SUBJ_PLAN_MSG = 'Subject <subjID> has no ready experiment plan.';
        USE_EXISTING_SUBJ_PLAN_QUES_MSG = 'Subject <subjID> has an experiment plan, file name:<fn>.\nContinue with this (1) or build a new plan (2) ?:';
        SUBJ_PLAN_EXISTS_EVT_NAME = 'SUBJ_PLAN_EXISTS';
        NO_SUBJ_PLAN_EXISTS_ERR_ID = 'EXP_MODEL:no_subj_plan';
        NO_SUBJ_PLAN_EXISTS_ERR_MSG = 'Subject has no ready experiment plan';
        GET_EXP_PARAMS_MSG = 'Please select a parameters file for the experiment';
        
        EXP_STATUS_FIRST_TIME = 'firstTime';
        EXP_STATUS_RE_RUN = 'reRun';
        EXP_STATUS_HAS_SUBJ_DETAILS = 'hasSubjDetails';
    end
    
    properties
        DataManager @uri_classes.common.ExperimentDataManager;
        subjID; % To be left empty. It exists only so that the getter function can be written.
        subjPlanFile @char; % the full path of the subject's experiment file.
        expRunStatus @char; % What is the status this experiment runs in? possible values exist in the constant section
    end
    
    methods
        
        function this = Experiment_Model()
            this.DataManager = uri_classes.common.ExperimentDataManager();
        end

        function setExperimentParametersFromFile(this,fileName)
            this.DataManager.importParametersNamesAndValuesFromFile(fileName);
        end
        
        function hasPlan = setCurrentSubjID(this,subjID)
            this.DataManager.setSubjID(subjID);
            [~,hasPlan] = this.checkSubjPlanExist(subjID);
        end
        
        function [fileNames,status] = checkSubjPlanExist(this,subjID)
            % Check if subject has experiment plan already:
            [fileNames,status] = this.retrieveSubjectPlanFiles(subjID);
        end
        
        function [subjExpTimelineFiles,status] = retrieveSubjectPlanFiles(this,subjID)
            % get the data model for a subject, to play a new experiment or
            % to resume an experiment stopped abruptly.
            [subjExpTimelineFiles,status] = this.DataManager.retrieveSubjectTimelineFiles(subjID);
            
        end
        
        function createSubjectPlan(this)
            % create and experiment plan for a subject. This should be
            % accessible from outside the experiment, i.e. this class
            % shouldn't be a part of a presenter in order to produce the
            % subject's plan.
            this.DataManager.experimentPlan = this.DataManager.createSubjectExperimentPlan();
            this.expRunStatus = this.EXP_STATUS_FIRST_TIME;
            % Also save the subject's plan:
            this.DataManager.saveExperimentPlan();
        end
        
        function useExistingPlan(this,planFN)
            this.DataManager.loadExperimentPlan(planFN);
        end
        
        function createMultiSubjectsPlan(this,subjIDs)
            % used for creating plans for multiple subjects at a time, in
            % case inter-subject counter-balancing is needed.
        end
        
        function id = get.subjID(this)
            id = this.DataManager.getSubjID();
        end
        
        function params = getExperimentParameters(this)
            params = this.DataManager.exportParameters();
        end
        
        function [subjInfo,subjInfoMeta] = getSubjInfo(this)
            [subjInfo,subjInfoMeta] = this.DataManager.getSubjInfo();
        end
        
        function setSubjInfo(this,subjInfo)
            this.DataManager.setSubjInfo(subjInfo);
        end
        
    end
    
end

