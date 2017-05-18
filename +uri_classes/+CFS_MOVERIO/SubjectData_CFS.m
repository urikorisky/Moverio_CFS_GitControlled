classdef SubjectData_CFS < uri_classes.common.ExperimentParameters
    %EXPERIMENTPARAMETERS_CFS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        PARAMS_SHEET_NAME = 'SubjData';
        PARAMS_INTERNAL_NAMES_XLSX_COL = 1;
        PARAMS_EXTERNAL_NAMES_XLSX_COL = 4;
        PARAMS_TYPES_XLSX_COL = 3;
        PARAMS_VALUES_XLSX_COL = 2;
        PARAMS_METADATA_XLSX_COL = [5:8];
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
            
            this.setPropsMetaDataFromList(...
                this.rawPropsFile(2:end,this.PARAMS_EXTERNAL_NAMES_XLSX_COL),...
                this.rawPropsFile(1,this.PARAMS_METADATA_XLSX_COL),...
                this.rawPropsFile(2:end,this.PARAMS_METADATA_XLSX_COL));
        end
        
    end
    
end

