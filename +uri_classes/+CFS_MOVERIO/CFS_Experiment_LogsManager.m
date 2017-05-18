classdef CFS_Experiment_LogsManager < uri_classes.common.LogsManager
    %CFS_EXPERIMENT_LOGSMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        RUN_LOG_FILENAME_TEMPLATE = 'Sub_<subjID>_<startTime>_ExperimentResults.mat';
        DEFAULT_LOG_FILE_NAME = 'runRowsLog';
    end
    
    properties
        trialLogFileFields @cell;
    end
    
    methods
        
        function setPerTrialRecordFieldNames(this,fieldNames)
            this.trialLogFileFields = fieldNames;
        end
        
        function logFile = createNewRunLog(this,subjID)
            logFile = this.addLogFile(this.DEFAULT_LOG_FILE_NAME,this.logDirs('logs').dirName,...
                this.createFileName(this.RUN_LOG_FILENAME_TEMPLATE,num2str(subjID)),...
                @uri_classes.common.FieldsAndValuesLogFile);
            % Set the fields in the log file:
            logFile.setFieldsNames(this.trialLogFileFields);
        end
        
        function logTrialResult(this,timelineObj,trialObj,trialResults)
            % FOR SIMPLICITY ONLY: I assume there's only one log here, the
            % "runRowsLog". If it doesn't exist, we create it.
            if(~this.logFiles.isKey(this.DEFAULT_LOG_FILE_NAME))
                warning('Default log file doesn''t exist! Creating one with subjID=-1!');
                this.createNewRunLog(-1);
            end
            event = this.logFiles(this.DEFAULT_LOG_FILE_NAME).getEmptyEvent;
            fieldsFromTrial = intersect(fields(trialObj.getProps),fields(event));
            % ahhh fuck it:
            for iField = 1:numel(fieldsFromTrial)
                event.(fieldsFromTrial{iField}) = trialObj.getProps.(fieldsFromTrial{iField});
            end
            for iCond = 1:numel(trialObj.getProps.Condition_Names)
                event.(trialObj.getProps.Condition_Names{iCond}) = ...
                    trialObj.getProps.Levels_Names{iCond};
            end
            [timelinePosFields,timelinePosValues] = timelineObj.getTimelinePosition;
            for iField = 1:numel(timelinePosFields)
                event.(timelinePosFields{iField}) = timelinePosValues(iField);
            end
            
            % ok now we put the actual trial results wtf:
            event.Fixation_Onset_timestamp = trialResults.startTime;
            event.CFS_Onset_timestamp = ''; % TODO!!!
            event.CFS_End_timestamp = trialResults.endTime;
            event.Shutter_Drop_timestamp = trialResults.events_flipTimes(1);
            if (~isempty(trialResults.keysPressed))
                [~,keyToTake] = min(trialResults.firstPressTimes); % take only the first key that was pressed
                event.Subject_Resp_Key = trialResults.keysPressed(keyToTake);
                event.Subject_Resp_timestamp = trialResults.firstPressTimes(keyToTake);
                import uri_classes.common.PTB_KbConsts
                if ((event.Subject_Resp_Key == PTB_KbConsts.LEFT) || ...
                        event.Subject_Resp_Key == PTB_KbConsts.MOUSE_LEFT)
                    event.Subject_Resp_Side = 'Left';
                end
                if ((event.Subject_Resp_Key == PTB_KbConsts.RIGHT) || ...
                        event.Subject_Resp_Key == PTB_KbConsts.MOUSE_RIGHT)
                    event.Subject_Resp_Side = 'Right';
                end
            end
            logFile = this.logFiles(this.DEFAULT_LOG_FILE_NAME);
            logFile.logEventInStructForm(event);
        end
        
        function logRecord = retreiveTrialRecord(this,trialObj)
            % assume only one log file:
            logFile = this.logFiles(this.DEFAULT_LOG_FILE_NAME);
            % Retrieve from this log file:
            recordNum = logFile.findRecordByValues(...
                'Trial',trialObj.ID,...
                'Code',trialObj.code...
                );
            logRecord = logFile.retrieveLogRecord(recordNum);
        end
        
        function updateTrialRecord_findRecord(this,trialObj,results)
            % assume only one log file:
            logFile = this.logFiles(this.DEFAULT_LOG_FILE_NAME);
            % Retrieve from this log file:
            recordNum = logFile.findRecordByValues(...
                'Trial',trialObj.ID,...
                'Code',trialObj.code...
                );  
            this.updateTrialRecord(results,recordNum);
        end
        
        function updateTrialRecord(this,newVals,recordNum)
            % assume only one log file:
            logFile = this.logFiles(this.DEFAULT_LOG_FILE_NAME);
            logFile.logEventInStructForm(newVals,recordNum);
        end
        
    end
    
end

