classdef FieldsAndValuesLogFile < uri_classes.common.LogFile
    %FIELDSANDVALUESLOGFILE A log file which has certain fields, into which
    %it saves values from successive events. Could be saved as a MAT file,
    %or XLSX, or TXT. Extend to include more file types.
    %   Detailed explanation goes here
    
    properties
        fieldsNames @cell;
        values @cell;
        fileType @double; % Which type of file to save.
    end
    
    properties (Constant)
        MAT_FILE_TYPE = 1;
        XLSX_FILE_TYPE = 2;
        TXT_FILE_TYPE = 3;
    end
    
    methods
        function this = FieldsAndValuesLogFile(name,filePath,fileName)
            this = this@uri_classes.common.LogFile(name,filePath,fileName);
            this.fileType = this.MAT_FILE_TYPE;
        end
        
        function setFieldsNames(this,fieldsNames)
            this.fieldsNames = fieldsNames;
            if (isempty(this.values))
                this.values = cell(0,numel(this.fieldsNames));
            end
            if (size(this.values,2)>numel(this.fieldsNames))
                warning('Log file: field names were updated, but there are more values in each record than there are fields.');
            end
             if (size(this.values,2)<numel(this.fieldsNames))
                warning('Log file: field names were updated, but there are less values in each record than there are fields.');
            end           
        end
        
        function evStruct = getEmptyEvent(this)
            fieldsAndEmpty = reshape(...
                [this.fieldsNames; repmat({[]},1,numel(this.fieldsNames))],...
                [1,2*numel(this.fieldsNames)]...
                );
            evStruct = struct(fieldsAndEmpty{:});
        end
        
        function logEventInStructForm(this,dataStruct,varargin)
            % varargin{1} = record number to replace
            evValues = cell(1,numel(this.fieldsNames));
            for iField = 1:numel(this.fieldsNames)
                evValues{iField} = dataStruct.(this.fieldsNames{iField});
            end
            if (~isempty(varargin))
                this.replaceRecord(evValues,varargin{1});
            else
                this.logEvent(evValues);
            end
        end
        
        function logEvent(this,evValues)
            this.values(end+1,:) = evValues;
            logEvent@uri_classes.common.LogFile(this,[]);
        end
        
        function replaceRecord(this,newVals,recordNum)
            this.values(recordNum,:) = newVals;
            % Is a bit of a problematic line:
            this.updateFile();
        end
        
        function logRecord = retrieveNbackLogRecord(this,nBack)
            % returns the n-th log record from the end. 0 is the last one,
            % 1 is the one before, etc. Notice that the last one recorded
            % is the one you're looking for if you're just after a trial
            % and looking for fixing a mistake!
            if (nBack>size(this.values,1))
                logRecord = [];
            end
            logRecord = retrieveLogRecord(this,size(this.values,1)-nBack);
        end
        
        function logRecord = retrieveLogRecord(this,recordNum)
            logRecord = this.getEmptyEvent();
            logRecordCellArr = this.values(recordNum,:);
            for iField = 1:numel(this.fieldsNames)
                logRecord.(this.fieldsNames{iField}) = ...
                    logRecordCellArr{strcmp(this.fieldsNames,this.fieldsNames{iField})};
            end
        end
        
        function recordNum = findRecordByValues(this,varargin)
            if (isempty(this.values))
                recordNum = -1;
            end
            % varargin: key-value pairs for search
            candidateRecords = true(size(this.values,1),1);
            for iKey = 1:2:(nargin-1)
                newCandidateRecords = logical(false(size(this.values,1),1));
                % search for records where this key contains this value.
                % The column holding this key:
                keyCol = strcmp(this.fieldsNames,varargin{iKey});
                % Compare the value, based on the type of data held there:
                switch(class(this.values{1,keyCol}))
                    case 'char'
                        newCandidateRecords = strcmp(this.values(:,keyCol),varargin{iKey+1});
                    case 'double'
                        newCandidateRecords = [this.values{:,keyCol}] == varargin{iKey+1};
                    otherwise
                        
                end
                candidateRecords = candidateRecords & newCandidateRecords';
            end
            recordNum = find(candidateRecords,1);
        end
        
        function status = appendDataToLogFile(this)
            status = appendDataToLogFile@uri_classes.common.LogFile(this);
            switch(this.fileType)
                case this.MAT_FILE_TYPE
                    status = this.appendToMATfile;
                otherwise
                        
            end
        end
        
        function status = appendToMATfile(this)
            fields = this.fieldsNames;
            values = this.values;
            try
                save(this.fullName,'fields','values');
            catch e
                status = 0;
                return;
            end
            status = 1;
        end
        
        function fileID = createFile(this,filePath,fileName)
            switch(this.fileType)
                case this.MAT_FILE_TYPE
                    % No need to create a file, they are created on-the-fly
                    % anew anyway(?)
                    fileID = 1;
                otherwise
                        
            end
        end
        
    end
    
end

