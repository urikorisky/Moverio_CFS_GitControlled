classdef CFS_TrialMistakeCodes
    %CFS_TRIALMISTAKECODES Constants describing mistakes done during trials
    %   Detailed explanation goes here
    
    properties (Constant)
        WRONG_SIDE = 1;
        WRONG_STIMULUS = 2;
        SUBJECT_CONFUSED = 3;
        OTHER = 4;
        
        codesLongDesc = ...
            {'Object placed on the wrong side'...
            ,'The wrong stimulus was presented'...
            ,'The subject was confused'...
            ,'Other'...
            };
        
        codesShortDesc = ...
            {'wrongSide'...
            ,'wrongStim'...
            ,'subjConfused'...
            ,'other'...
            }
            
    end
    
    methods
    end
    
end

