classdef LogFile <handle
   
    properties
        fileID @double;
        fileName @char;
        filePath @char;
        logName @char; % short name to be used to access this log file
        type @char;
        fileIsUpdated @logical;
        saveOnline @logical;
    end
    
    methods
        
        function this = LogFile(name,filePath,fileName)
%             this.fileID = this.createFile(filePath,fileName);
%             if (this.fileID == -1)
%                 error (['Could not create log file: "' filePath,fileName '". Program Aborted.']);
%             end
            this.fileName = fileName;
            this.filePath = filePath;
            this.logName = name;
            this.fileIsUpdated = false; 
            this.saveOnline = true;
        end
        
        function fileID = createFile(this,fileName,filePath)
            % for each subclass to implement by itself. does not work for superclass.
            fileID = -1;
        end
        
        function logEvent(this,event)
            % each subclass should choose its own format for the event data, e.g.: txt = string, xls = cell
            % array etc.
            this.fileIsUpdated = false;
            if(this.saveOnline)
                this.updateFile();
            end
        end
        
        function fullPath = fullName(this)
            fullPath = [this.filePath this.fileName];
        end

        function updateFile(this)
            if (this.fileIsUpdated)
                return;
            end
            status = this.appendDataToLogFile();
            if (status)
                this.fileIsUpdated = true;
            end
        end
        
        function status = appendDataToLogFile(this)
            if (isempty(this.fileID))
                this.fileID = this.createFile(this.filePath,this.fileName);
            end
            status = 0;
            % left for the subclasses to implement, depends on the file
            % type they wish to save.
        end
        
    end
end