classdef Experiment_Plan_Factory_SessBlockTrial < uri_classes.common.Experiment_Plan_Factory
    %EXPERIMENT_PLAN_FACTORY_SESSBLOCKTRIAL An implementation of the
    %Experiment_Plan_Factory class to a specific Session->Block->Trial structure.
    %   Detailed explanation goes here
    
    properties (Constant)
        DEFAULT_MAX_BACKTRACK_TRIES = 5;
    end
    
    properties
        numSessions @double;
        blocksPerSession @double; % Either a scalar, or a vector specifying each session
        trialsPerBlock @double; % Either a scalar, or a vector specifying each block.
                                % If block quantity also varies between
                                % sessions, a matrix of dimensions
                                % numSessionsXnumBlocks
    end
    
    methods
        
        function this = Experiment_Plan_Factory_SessBlockTrial()
            this.createPropsMap({'Number_Of_Sessions','Blocks_Per_Session','Trials_Per_Block'},...
                {'numSessions','blocksPerSession','trialsPerBlock'});
            % Initializing to default values:
            this.numSessions = 1;
            this.blocksPerSession = 1;
            this.trialsPerBlock = 0;
        end
        
        function timeline = produceExperimentTimeline(this)
            timelineClass = [this.TIMELINE_CLASS];
            timeline = timelineClass();
            for iSess = 1:this.numSessions
                currSess = this.createSession(iSess);
                currSess.ID = iSess;
                timeline.addSession_ByObject(currSess);
            end
        end
        
        function session = createSession(this,sessNum)
            session = uri_classes.common.Experiment_Timeline_Session();
            for iBlock = 1:this.blocksInSession(sessNum)
                currBlock = this.createBlock(sessNum,iBlock);
                currBlock.ID = iBlock;
                session.addBlock_ByObject(currBlock);
            end
        end
        
        function block = createBlock(this,sessNum,blockNum)
            block = uri_classes.common.Experiment_Timeline_Block();
            trialsNum = this.trialsInBlock(sessNum,blockNum);
            block.createTrialsList_ByObjects(this.create_a_ListOfTrials(trialsNum));
        end
        
        
        
        function listOfTrials = create_a_ListOfTrials(this,numTrials)
            % This can only be called after the conditions (and possibly constraints) were defined!
            fprintf('\nLooking for a trials list...\n');
            fprintf(['|' repmat('-',1,numTrials-2) '|\n']);
%             [order,status] = this.findConstrainedOrder(numTrials,[],...
%                 this.getCondsLevelsCount(numTrials),this.DEFAULT_MAX_BACKTRACK_TRIES);
            [order,status] = this.getListOfTrialsLevels(numTrials);
            fprintf('\n');
            if (~status)
                error('\nCouldn''t find a list of trials! Try again or change requirements.\n');
            end
            listOfTrials = cell(1,size(order,1));
            for iTrial = 1:numel(listOfTrials)
                % Create the trials one-by-one, and add to the list:
                currTrial = this.createTrialWithConds(order(iTrial,:));
                currTrial.ID = iTrial;
                listOfTrials{iTrial} = currTrial;
            end
        end
        
        function [order,status] = getListOfTrialsLevels(this,numTrials)
            % while not exactly needed, this is good for inserting
            % pseudo-conditions in subclasses. Bad coding.
            [combs,combsCounts] = this.getCondsLevelsCount(numTrials);
            [order,status] = this.findConstrainedOrder(numTrials,[],...
                combs,combsCounts,this.DEFAULT_MAX_BACKTRACK_TRIES);
        end
        
        function trial = createTrialWithConds(this,trialCondsLevels)
            trial = this.getEmptyTrial();
            trialProps = trial.getProps;
            % set the properties we want to enter:
%             trialProps.Code = strrep(num2str(trialCondsLevels),' ',''); % Trial code is a combination of the levels
            trialProps.Code = sum(trialCondsLevels.*(10.^[numel(trialCondsLevels)-1:-1:0])); % Trial code is a combination of the levels
            trialProps.Condition_Names = {this.conds(:).name};
            trialProps.Levels_Names = this.getLevelsNames(trialCondsLevels);
            trialProps.Levels_Numbers = trialCondsLevels;
            trial.setProps(trialProps);
        end
        
        function trial = getEmptyTrial(this)
            trial = uri_classes.common.Experiment_Timeline_Trial();
        end
        
        function numTrials = trialsInBlock(this,sessNum,blockNum)
            if (size(this.trialsPerBlock,1)>1)
                % A matrix, each block in each session has #trials
                % sepcified:
                numTrials = this.trialsPerBlock(sessNum,blockNum);
            else
                if (size(this.trialsPerBlock,2)>1)
                    % A vector, each block inside a session has #trials
                    % specified, same for all sessions:
                    numTrials = this.trialsPerBlock(blockNum);
                else
                    % A scalar, same trials num for all blocks.
                    numTrials = this.trialsPerBlock;
                end
            end
        end
        
        function numBlocks = blocksInSession(this,sessNum)
            if (size(this.blocksPerSession,2)>1)
                % A vector, each block inside a session has #trials
                % specified, same for all sessions:
                numBlocks = this.blocksPerSession(sessNum);
            else
                % A scalar, same trials num for all blocks.
                numBlocks = this.blocksPerSession;
            end
        end
        
        function timeline = importExperimentTimeline(this,timelineInfo)
            % Import a timeline that was exported, and return an object of
            % type Experiment_Timeline
            timeline =  uri_classes.common.Experiment_Timeline_SBT_Base();
            timeline.importInfo(timelineInfo);
        end
        
    
    

        function classPointer = TIMELINE_CLASS(this)
            % fuck you MATLAB, with your stupid OOP implementation
             classPointer = @uri_classes.common.Experiment_Timeline_SBT_Base;
        end
    end
    
end

