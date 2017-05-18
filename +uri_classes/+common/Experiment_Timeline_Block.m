classdef Experiment_Timeline_Block < uri_classes.common.Experiment_Timeline
    %EXPERIMENT_TIMELINE_BLOCK An implementation of the class "Timeline" in
    %a shape of a block
    
    properties
        blockType @char; %Type of block.
        code @double; %if exists, code for this block.
        ID @double; % ID of block within parent session.
        trials; % An alais of the steps sequence property.
    end
    
    methods
        
        function this = Experiment_Timeline_Block()
            this.createPropsMap({'Block_ID','Code','Block_Type'},...
                {'ID','code','blockType'})
        end
        
        function createTrialsList_ByInfo(this,trialInfos)
            for iBlock = 1:numel(trialInfos)
                this.addTrial_ByInfo(trialInfos{iBlock});
            end
        end
        
        function createTrialsList_ByObjects(this,trials)
            for iBlock = 1:numel(trials)
                this.addTrial_ByObject(trials{iBlock});
            end
        end
        
        function addTrial_ByInfo(this,trialInfo)
            this.insertStep(trialInfo);
        end
        
        function addTrial_ByObject(this,trial)
            this.stepsList{end+1} = trial;
        end
        
        function start(this)
            start@uri_classes.common.Experiment_Timeline(this);
            % should start running the blocks from the beginning:
            this.nextStep();
        end
        
        function insertStep(this,stepInfo)
            newTrial = uri_classes.common.Experiment_Timeline_Trial();
            newTrial.importInfo(stepInfo);
            this.stepsList{end+1} = newTrial;
        end
        
        function infoObj = exportInfo(this)
            infoObj.props = this.getThisLevelInfo();
            trialsInfo = cell(numel(this.trials),1);
            for iTrial = 1:numel(trialsInfo)
                trialsInfo{iTrial} = this.trials{iTrial}.exportInfo();
            end
            infoObj.trials=trialsInfo;
        end
        
        function importInfo(this,blockInfo)
            this.setProps(blockInfo.props);
            this.createTrialsList_ByInfo(blockInfo.trials);
        end
        
        function thisLevelInfo = getThisLevelInfo(this)
            thisLevelInfo = this.getProps();
        end
        
        function trialSeq = get.trials(this)
            trialSeq = this.stepsList;
        end

        function readableForm = print(this)
%             readableForm = {'Session','Block','Trial','Code','Ended?'};
            for iTrial = 1:numel(this.trials)
                trialReadableForm = this.trials{iTrial}.print;
                readableForm(iTrial,:) = ...
                    [iTrial,trialReadableForm];
            end
        end
        
    end
    
end

