classdef PlainTextLogFile < uri_classes.common.LogFile
   
    properties
        rows @char;
    end
    
    methods
        function this = PlainTextLogFile(name,filePath,fileName)
            this = this@uri_classes.common.LogFile(name,filePath,fileName);
            this.type = 'text';
        end
        
        function fileID = createFile(this,filePath,fileName)
            fileID = fopen([filePath fileName],'a');
        end
        
        function logEvent(this,event)
            this.rows = sprintf('%s%s\n',this.rows,event);
        end
                
    end 
end