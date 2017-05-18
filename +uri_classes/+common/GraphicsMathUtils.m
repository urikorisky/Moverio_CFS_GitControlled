classdef GraphicsMathUtils
    %GRAPHICSMATHUTILS Static class with functions that help with
    %calculations related to graphics
    
    properties
    end
    
    methods (Static)
        function [ratioInPow2, newFittedRec, exactRatio] = fitRectInRectPow2(fittedRect,targetRect)

            fits = false; % flag for fitting
            ratioInPow2 = 1;
            exactRatio = 1;
            while (~fits)
                newFittedRec = fittedRect*ratioInPow2;
                fits = true;
                % compare widths and heights:
                if ((newFittedRec(3)-newFittedRec(1))>(targetRect(3)-targetRect(1)))
                    fits = false; %width of fitted rect bigger
                end
                if ((newFittedRec(4)-newFittedRec(2))>(targetRect(4)-targetRect(2)))
                    fits = false; %height of fitted rect bigger
                end
                if (~fits)
                    ratioInPow2 = ratioInPow2/2;
                end
            end
            
            % also give exact ratio along the larger dimension:
            exactRatio = uri_classes.common.GraphicsMathUtils.findExactRatioForRects(fittedRect,targetRect);
            
        end
        
        function exactRatio = findExactRatioForRects(rectA,rectB)
            % returns the ration rectB/rectA, with the largest dimension
            % considered for calculation:
            
%             if ((rectA(3)-rectA(1))>(rectA(4)-rectA(2)))
%                 exactRatio = (rectB(3)-rectB(1))/(rectA(3)-rectA(1));
%             else
%                 exactRatio = (rectB(4)-rectB(2))/(rectA(4)-rectA(2));
%             end
            exactRatio = min((rectB(3)-rectB(1))/(rectA(3)-rectA(1)),(rectB(4)-rectB(2))/(rectA(4)-rectA(2)));
        end
        
    end
    
end

