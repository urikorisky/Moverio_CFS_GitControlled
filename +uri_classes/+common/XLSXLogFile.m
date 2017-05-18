classdef XLSXLogFile < uri_classes.common.LogFile
   
    properties
        headerLine @cell;
        rows @cell;
        isPreAllocated @logical;
        currRowIdx=0;
        sheetName = 'Default';
    end
    
    methods
        
        function this = XLSXLogFile(name,filePath,fileName)
            this = this@uri_classes.common.LogFile(name,filePath,fileName);
            this.type = 'excel';
            this.rows = {};
            this.isPreAllocated = false;
        end
        
        function preAllocate(this,numRows)
            if (isempty(this.headerLine))
                error ('Headers of XLS file not set yet!');
            end
            this.isPreAllocated = true;
            this.rows = cell(numRows,numel(this.headerLine));
        end
        
        function fileID = createFile(this,filePath,fileName)
            % XLSX files don't have to be created ahead, but we create it just to be sure it works:
%             status = xlswrite([filePath,fileName],{''},this.sheetName);
%URI: TEMP!!!: 
            status=1;
            if (status)
                fileID = 1;
            end
        end
        
        function setHeader(this,varargin)
            if (iscell(varargin{1}))
                this.headerLine = varargin{1};
            else
                newHeaderLine = cell(1,numel(varargin));
                for iHeader = 1:numel(varargin)
                    newHeaderLine{iHeader} = varargin{iHeader};
                end
                this.headerLine = newHeaderLine;
            end
        end
        
        function logEvent(this,event)
            % Event can be: 
            % 1)a cell array of values, with the same numel as the headersLine. Assignment is serial.
            % 2)a struct with fields matching the headers, assignment accordingly.
            % 3)another enumerable structure, length equivalent to number of columns, and convertable to cell
            
            if (iscell(event))
                this.addToRows(event);
%                 this.rows(this.nextLine) = event;
            elseif (isstruct(event))
                newRow = cell(1,numel(this.headerLine));
                structFields = fields(event);
                for iField = 1:numel(structFields)
                    col=ismember(this.headerLine,structFields{iField});
                    newRow(col) = event.(structFields{iField});
                end
                this.addToRows(newRow);
            elseif (numel(event)==numel(this.headerLine))
                try
                    this.addToRows(num2cell(event));
                catch
                    warning ('Could not log the event!');
                end
            end
        end
        
        function addToRows(this,newRow)
            this.rows(this.nextLine,:) = newRow;
            
            this.currRowIdx = this.currRowIdx+1;
        end
        
        function lineNum = nextLine(this)
            if (this.isPreAllocated)
                lineNum = this.currRowIdx + 1;
            else
                lineNum = size(this.rows,1) + 1;
            end
        end
        
        function outStruct = toStruct(this)
            
        end
        
        function outCell = toCell(this,withHeaders)
            % I trust MATLAB's default behavior to return an empty matrix if rows are empty
            if (withHeaders)
                outCell = [this.headerLine;this.rows(1:this.currRowIdx,:)];
            else
                outCell = this.rows(1:this.currRowIdx,:);
            end
        end
        
        function status = updateFile(this)
            status = xlswrite(this.fullName,this.toCell(true),this.sheetName);
        end
    end
    
end