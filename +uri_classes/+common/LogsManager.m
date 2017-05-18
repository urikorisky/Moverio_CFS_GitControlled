classdef LogsManager < handle
    
    properties (Constant)
        SUBJ_PLAN_TEMPLATE = 'Sub_<subjID>_<startTime>_ExperimentPlan.mat';
        SUBJ_PLAN_PRINT_TEMPLATE = 'Sub_<subjID>_<startTime>_ExperimentPlan.xlsx';
    end
    
    properties
        logDirs @containers.Map; % a dictionary of structures('dirName','path')
        logFiles @containers.Map; % a dictionary of uri_classes.common.LogFile objects
        expStartTime; %timestamp for exp start. externally set.
    end
    
    methods
        
        function this = LogsManager()
            this.logDirs = containers.Map();
            this.logFiles = containers.Map();
        end
        
        function createLogDir(this,dirName,dirPath)
            if (exist (dirPath,'dir'))
                warning(['In LogsManager: Logs Directory "' dirPath '" already exists.']);
            else
                mkdir(dirPath);
            end
            this.logDirs(dirName) = struct('dirName',dirName,'path',dirPath);
        end
        
        function logFileObj = addLogFile(this,logName,dirName,fileName,logFileClass)
            if (~isKey(this.logDirs,dirName))
                error ('Folder doesnt exist!');
            end
            if (nargin<5)
                % default to logFile class:
                newLogFileClass = @uri_classes.common.LogFile;
            else
                % use provided logFile class pointer:
                newLogFileClass = logFileClass;
            end
            newLogFile = newLogFileClass(logName,this.logDirs(dirName).path,fileName);
            if (isempty(newLogFile))
                % log file creation failed - exit
                error (['Creation of log file "' logName '" in "' this.logDirs(dirName).dirPath '/' fileName '" failed']);
            end
            this.logFiles(logName) = newLogFile;
            logFileObj = newLogFile;
        end
        
        function logEvent(this,logName,event)
            currLog = this.logFiles(logName);
            currLog.logEvent(event); %% IF DATA IS NOT REALLY LOGGED, THEN THIS LINE IS TO BLAME! (if the log is not a reference, but a copy...)
        end
        
        function closeLog(this,logName)
            % writes a log to a file:
            currLog = this.logFiles(logName);
            currLog.updateFile();
        end
        
        function [timelineFN,status] = findSubjExpTimeline(this,subjID)
            % looks for an existing experiment timeline files(s) for this subject.
            % Returns the name of the file(s) if exists.
            fnTemplate = strrep(this.SUBJ_PLAN_TEMPLATE,'<startTime>','*');
            fnTemplate = strrep(fnTemplate,'<subjID>','%s');
            [timelineFN,status] = this.findLogFile(...
                fnTemplate,...
                num2str(subjID));
        end
        
        function [logFN,status] = findLogFile(this,varargin)
            % inputs:
            % 1) template of the log file name
            % 2-end) variables for the file name
            % status: 0 if nothing found, 1 if found, 2 if more than 1 is
            % found            
            status = 0;
            logFN = {};
            dirResults = struct([]);
            dirsToSearch = keys(this.logDirs);
            filesFoundPaths = {};
            for iDir=1:numel(dirsToSearch)
                filesInThisDir = dir([...
                    this.logDirs(dirsToSearch{iDir}).path '/'...
                    sprintf(varargin{1},varargin{2:end}) ...
                    ]);
                if (isempty(dirResults))
                    dirResults = filesInThisDir;
                else
                    dirResults(end+1:end+numel(filesInThisDir)) = filesInThisDir;
                end
                filesFoundPaths = [filesFoundPaths ...
                    repmat({[this.logDirs(dirsToSearch{iDir}).path '/']},...
                    numel(filesInThisDir),1)];
            end
            if (isempty(dirResults))
                return;
            end
            status = 1;
            if (numel(dirResults)==1)
                logFN = {[filesFoundPaths{1} dirResults(1).name]};
                return;
            end
            status = 2;
%             sort dirResults by date, sort paths respectively:
            [~,sortIdxs] = sort([dirResults.datenum],'descend');
            dirResults = dirResults(sortIdxs);
            for iFile = 1:numel(dirResults)
                logFN = [logFN; {[filesFoundPaths{iFile} dirResults(iFile).name]}];
            end
        end
        
        function flushAllLogsToFiles(this)
            % Writes (or updates) all the log files.
            % Use cases:
            % 1) When the program is idle and the data needs to be saved
            % 2) Upon sudden termination of the program
            % 3) When the saving of experiment data has to be done on-line, because the experimenter monitors
            % the results. Consider updating just the needed data in that case, and not all the logs.
            allFilesKeys = keys(this.logFiles);
            for iFile = 1:numel(allFilesKeys)
                this.logFiles(allFilesKeys{iFile}).updateFile();
            end
            
        end
        
        function defaultLogDirectory = defaultLogDir(this)
            % returns a string with the path of a log dir to which misc log files can be saved.
            % Will return FALSE or an empty string if no such dir was set
            if(isempty(this.logDirs.keys))
                defaultLogDirectory = false;
            end
            dirs = this.logDirs.keys;
            defaultLogDirectory = this.logDirs(dirs{1}).path;
        end
        
        function [mat_fileName,xls_fileName] = createExpPlanFileName(this,subjID)
            mat_fileName = this.createFileName(this.SUBJ_PLAN_TEMPLATE,num2str(subjID));
            xls_fileName = this.createFileName(this.SUBJ_PLAN_PRINT_TEMPLATE,num2str(subjID));
        end
        
        function fileName = createFileName(this,fileNameTemplate,varargin)
            fileName = fileNameTemplate;
            fileName = strrep(fileName,'<startTime>',uri_classes.common.LogsManager.formatTimeToString(this.expStartTime));
            fileName = strrep(fileName,'<subjID>','%s');
            fileName = sprintf(fileName,varargin{:});
        end
        
    end
    
    methods (Static)
        function str = formatTimeToString(timeVector)
            str = datestr(timeVector,'dd-mm-yyyy_HH-MM-SS');
        end        
    end
    
end