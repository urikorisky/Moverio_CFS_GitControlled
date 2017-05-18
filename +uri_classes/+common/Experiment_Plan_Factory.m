classdef Experiment_Plan_Factory < uri_classes.common.PropertiesMappedHandle
    %EXPERIMENT_PLAN_FACTORY Creates objects of type "Experiment_Timeline"
    
    
    properties
        constraints @struct; % <conds, reps>
        conds @struct; %<Name (string), levels(cell of string), levels_proportions (double vector)>
    end
    
    methods
        
        function this = Experiment_Plan_Factory()
            this.constraints = struct([]);
            this.conds = struct([]);
            rng('shuffle');
        end
        
        function addCondition(this,condName,condLevels,condLevelProportions)
            condIdx = size(this.conds,2)+1;
            this.conds(condIdx).name = condName;
            this.conds(condIdx).levels = condLevels;
            if (isempty(condLevelProportions))
                condLevelProportions = ones(1,numel(condLevels));
            end
            this.conds(condIdx).lvlsProportions = condLevelProportions; % This normalization isn't needed: /sum(condLevelProportions);
        end
        
        function removeCondition(this,condIdentifier)
            % remove a condition using its index or name.
            % used for removing pseudo-conditions, like stimulus ID.
            % bad coding.
            if(ischar(condIdentifier))
                % condition is identified by name. Otherwise it's its index
                condIdentifier = find(strcmp({this.conds(:).name},condIdentifier));
            end
            this.conds(condIdentifier) = [];
        end
        
        function addConstraint(this,constraintConds,constraintRepNum)
            constIdx = size(this.constraints,2)+1;
            this.constraints(constIdx).conds = constraintConds;
            this.constraints(constIdx).reps = constraintRepNum;
        end
        
        function produceExperimentTimeline()
            % This should be implemented in subclasses, as the definition
            % of blocks, trials etc. is fluid.
        end
        
        function [order,status] = findConstrainedOrder(this,numEntries,existingEntries,combs,combsCount,maxTries)
            % condsCount - a MXN matrix. M=number of conditions. N=number
            % of levels (is max number of levels across conditions).
            % Contains the number of trials in which each level is used.
            % The algorithm will choose a random combination of levels from
            % each condition for each trial.
            status = 0; %failed
            tries = 0;
            longestConstraint = this.findLongestConstraint();
            fprintf(repmat('*',1,min(numEntries,longestConstraint)));
            order = [];
            if (numEntries == 0)
                status = 1;
                return;
            end
            orderIsConstrained = 0;
            while(tries<maxTries && ~orderIsConstrained)
                [order, updatedCombsCount]= this.createOrder(longestConstraint,combs,combsCount);
                if (isempty(existingEntries))
                    orderIsConstrained = this.validateOrder(order);
                else
                    orderIsConstrained = this.validateOrder([existingEntries;order]);
                end
                tries = tries+1;
            end
            if(~orderIsConstrained)
                status = 0;
                order = [];
                fprintf(repmat('\b',1,longestConstraint));
                return;
            end
            
            tries = 0;
            restIsConstrained = 0;
            while(tries<maxTries && ~restIsConstrained)
                [restOfOrder,restIsConstrained] = this.findConstrainedOrder(...
                    numEntries-longestConstraint,order(2:end,:),combs,updatedCombsCount,maxTries);
                tries = tries+1;
            end
            if(~restIsConstrained)
                status = 0;
                order = [];
                fprintf(repmat('\b',1,longestConstraint));
                return;
            end
            order = [order;restOfOrder];
            status = 1;
        end
        
        function [order, updatedCombsCount]=createOrder(this,numEntries,combs,combsCount)
            % NOTICE: changed from previous version (3)
            %TODO: do this smarter than a 5th grader could
            order = zeros(numEntries,size(combs,2));
            for iEntry = 1:numEntries
                    combsNotZero = find(combsCount>=1);
                    combToTake = combsNotZero(randperm(numel(combsNotZero)));
                    combToTake = combToTake(1);
                    order(iEntry,:) = combs(combToTake,:);
                    combsCount(combToTake) = combsCount(combToTake)-1;
            end
            updatedCombsCount = combsCount;
        end
        
        function [isConstrained] = validateOrder(this,order)
            isConstrained = true;
            for iConst = 1:numel(this.constraints)
                repsIndices = ...
                    uri_classes.common.Experiment_Plan_Factory.findRepeatsInSeq(...
                    order(:,this.constraints(iConst).conds),...
                    this.constraints(iConst).reps);
                isConstrained = isempty(repsIndices)&isConstrained;
            end
        end
        
        function longestConstraint = findLongestConstraint(this)
            longestConstraint = max([this.constraints.reps]);
        end
        
        function [combinations,counts] = getCondsLevelsCount(this,numEntries)
            % This function was changed from the previous version (3)
            % because I understood the algorithm was flawed.
            % go over all the combinations of the conditions' levels
            numelInCell = @(x) numel(x);
            levelsNums = cellfun(numelInCell,{this.conds.levels});
            numCombinations = prod(levelsNums);
            combinations = ...
                uri_classes.common.Experiment_Plan_Factory.recMakeAllPossibleSelectionsMat(levelsNums(:));
            counts = zeros(numCombinations,1);
            for iComb = 1:numCombinations
                currCombReps = 1;
                for iCond = 1:numel(this.conds)
                    currCombReps = currCombReps*this.conds(iCond).lvlsProportions(combinations(iComb,iCond));
                end
                counts(iComb) = currCombReps;
            end
            if (~isempty(numEntries))
                counts = counts*(numEntries/sum(counts));
            end
            
        end
        
        function levelsNames = getLevelsNames(this,condsLevels)
            levelsNames = cell(1,numel(this.conds));
            for iCond = 1:numel(condsLevels)
                levelsNames{iCond} = this.conds(iCond).levels{condsLevels(iCond)};
            end
        end
        
    end
    
    methods (Static)
        function [ repsIndices ] = findRepeatsInSeq( seq,repTimes )
            import uri_classes.common.external.findsubmat;
            % will probably be done better with regexp() but I don't know how to do that
            repsIndices = [];
            uniqueVals = unique(seq,'rows');
            for iVal = 1:size(uniqueVals,1)
%                 repsIndices = [repsIndices, find(ismember(seq,ones(repTimes,size(uniqueVals,2)).*uniqueVals(iVal)))];
                subMat = repmat(uniqueVals(iVal,:),repTimes,1);
                if (numel(subMat) == numel(seq))
                    currRepsEntries = find(isequal(seq,subMat));
                else
                    [currRepsEntries,~] = findsubmat(seq,subMat);
                end
                
                repsIndices = [repsIndices, currRepsEntries];
            end

        end
        
        function outMat = recMakeAllPossibleSelectionsMat(varargin)
            levels = varargin{1};
            if (numel(levels) == 1)
                outMat = [1:levels(1)]';
                return;
            end
            numCombs = prod(levels);
            outMat = zeros(numCombs,numel(levels));
            numLevels = levels(1);
            for iLevel = 1:numLevels
                outMat((iLevel-1)*(numCombs/numLevels)+1:iLevel*(numCombs/numLevels),:) = ...
                    [repmat(iLevel,numCombs/numLevels,1) uri_classes.common.Experiment_Plan_Factory.recMakeAllPossibleSelectionsMat(levels(2:end))];
            end
        end
        
    end
    
end

