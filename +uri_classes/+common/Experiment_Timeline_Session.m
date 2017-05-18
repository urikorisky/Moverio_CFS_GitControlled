classdef Experiment_Timeline_Session < uri_classes.common.Experiment_Timeline
    %EXPERIMENT_TIMELINE_BLOCK An implementation of the class "Timeline" in
    %a shape of a block
    
    properties
        sessType @char; %Type of block.
        code @double; %if exists, code for this block.
        ID @double; % ID of block within parent session.
        blocks; % An alais of the steps sequence property.
    end
    
    methods
        
        function this = Experiment_Timeline_Session()
            this.createPropsMap({'Session_ID','Code','Session_Type'},...
                {'ID','code','sessType'})
        end
        
        function createBlocksList_ByInfo(this,blockInfos)
            for iBlock = 1:numel(blockInfos)
                this.addBlock_ByInfo(blockInfos{iBlock});
            end
        end
        
        function createBlocksList_ByObjects(this,blocks)
            for iBlock = 1:numel(blocks)
                this.addBlock_ByObject(blocks{iBlock});
            end
        end
        
        function addBlock_ByInfo(this,blockInfo)
            this.insertStep(blockInfo);
        end
        
        function addBlock_ByObject(this,block)
            this.stepsList{end+1} = block;
        end
        
        function start(this)
            start@uri_classes.common.Experiment_Timeline(this);
            % should start running the blocks from the beginning:
            this.nextStep();
        end
        
        function insertStep(this,stepInfo)
            newBlock = uri_classes.common.Experiment_Timeline_Block();
            newBlock.importInfo(stepInfo);
            this.stepsList{end+1} = newBlock;
        end
        
        function infoObj = exportInfo(this)
            infoObj.props = this.getThisLevelInfo();
            blocksInfo = cell(numel(this.blocks),1);
            for iBlock = 1:numel(blocksInfo)
                blocksInfo{iBlock} = this.blocks{iBlock}.exportInfo();
            end
            infoObj.blocks=blocksInfo;
        end
        
        function importInfo(this,sessInfo)
            this.setProps(sessInfo.props);
            this.createBlocksList_ByInfo(sessInfo.blocks);
        end
        
        function thisLevelInfo = getThisLevelInfo(this)
            thisLevelInfo = this.getProps();
        end
        
        function blocksSeq = get.blocks(this)
            blocksSeq = this.stepsList;
        end
        
        function readableForm = print(this)
%             readableForm = {'Session','Block','Trial','Code','Ended?'};
            readableForm = {};
            for iBlock = 1:numel(this.blocks)
                blockReadableForm = this.blocks{iBlock}.print;
                readableForm(end+1:end+size(blockReadableForm,1),:) = ...
                    [num2cell(repmat(iBlock,size(blockReadableForm,1),1)),blockReadableForm];
            end
        end
        
    end
    
end

