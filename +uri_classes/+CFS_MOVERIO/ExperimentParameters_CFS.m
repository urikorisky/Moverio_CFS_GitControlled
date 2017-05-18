classdef ExperimentParameters_CFS < uri_classes.common.ExperimentParameters
    %EXPERIMENTPARAMETERS_CFS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        PARAMS_SHEET_NAME = 'Params';
        PARAMS_INTERNAL_NAMES_XLSX_COL = 1;
        PARAMS_EXTERNAL_NAMES_XLSX_COL = 4;
        PARAMS_TYPES_XLSX_COL = 3;
        PARAMS_VALUES_XLSX_COL = 2;
        
        STIMULI_SHEET_NAME = 'Stimuli';
        STIMULI_IDS_COL = 1;
        STIMULI_NAMES_COL = 2;
        STIMULI_REPEATS_PROPORTIONS_COL = 3;
        
        DATA_LOG_PER_TRIAL_SHEET_NAME = 'LogPerTrial';
        DATA_LOG_PER_TRIAL_FIELDS_NAMES_COL = 1;
    end
    
    properties
        stimuliTable = {};
        stimuli @struct; % a link to get the stimuli in an orderly fashion. Assigned through a getter.
        numStims @double; %number of stimuli in this experiment
        trialDataLogFields = {};
    end
    
    methods
        
        function setPropsNamesAndValuesFromFile(this,fn)
            % we only read XLSXs here, son.
            % Read the XLSX file that was selected (usually by the parent
            % object), the sheet name is specified for this class.
            [~,~,this.rawPropsFile] = xlsread(fn,this.PARAMS_SHEET_NAME);
            % Call the superclass's function that creates these properties
            % so that they will be mapped (will have the convinient
            % one-shot getter\setter functions) and inserts the values that
            % are noted in the XLSX file:
            this.setPropsNamesAndVariablesFromList(...
                this.rawPropsFile(2:end,this.PARAMS_EXTERNAL_NAMES_XLSX_COL),...
                this.rawPropsFile(2:end,this.PARAMS_INTERNAL_NAMES_XLSX_COL),...
                this.rawPropsFile(2:end,this.PARAMS_TYPES_XLSX_COL),...
                this.rawPropsFile(2:end,this.PARAMS_VALUES_XLSX_COL));
            
            [~,~,this.stimuliTable] = xlsread(fn,this.STIMULI_SHEET_NAME);
            this.stimuliTable = this.stimuliTable(2:end,:);
            this.addProps({'Stimuli_List','Number_Of_Stimuli'},{'stimuli','numStims'});
            
            this.readLogDataPerTrialFieldsFromFile(fn);
        end
        
        function readLogDataPerTrialFieldsFromFile(this,fn)
            [~,~,fieldNames] = xlsread(fn,this.DATA_LOG_PER_TRIAL_SHEET_NAME);
            this.trialDataLogFields = fieldNames(:,this.DATA_LOG_PER_TRIAL_FIELDS_NAMES_COL)';
        end
        
        function [conds,levels,proportions] = listCondsAndLevels(this)
            conds = cell(1,this.numConds);
            levels = cell(1,this.numConds);
            proportions = cell(1,this.numConds);
            for iCond = 1:this.numConds
                conds{iCond} = this.(sprintf('cond_%d_name',iCond));
                levels{iCond} = this.(sprintf('cond_%d_levels',iCond));
                proportions{iCond} = this.(sprintf('cond_%d_lvlsProportions',iCond));
            end
        end
        
        function [conds,reps] = listConstraintsAndReps(this)
            conds = cell(1,this.numConstraints);
            reps = cell(1,this.numConstraints);
            for iConst = 1:this.numConstraints
                conds{iConst} = this.(sprintf('constraint_%d_conds',iConst));
                reps{iConst} = this.(sprintf('constraint_%d_maxReps',iConst));
            end
        end
        
        function stimuliData = get.stimuli(this)
            stimuliData = struct();
            stimuliData.ID = this.stimuliTable(:,this.STIMULI_IDS_COL);
            stimuliData.name = this.stimuliTable(:,this.STIMULI_NAMES_COL);
            stimuliData.repProportions = this.stimuliTable(:,this.STIMULI_REPEATS_PROPORTIONS_COL);
        end
        
        function numOfStims = get.numStims(this)
            numOfStims = size(this.stimuliTable,1);
        end
        
    end
    
end

