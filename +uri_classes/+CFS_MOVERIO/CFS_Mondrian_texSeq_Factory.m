classdef CFS_Mondrian_texSeq_Factory < uri_classes.CFS_MOVERIO.CFS_texSeq_Factory
    %CFS_MONDRIAN_TEXSEQ_FACTORY Creates a sequence of mondrian PTB textures and their display times,
    %according to properties it receives
    %   
    
    properties
    end
    
    methods (Static)
        function [textures_and_frames] = createSeq(CFS_seq_props,PTB_window,mondrianTexturesToUse,fixationTexture)
            % This class only creates the mondrians, in which nothing changes along the trial - it's just 10Hz
            % of mondrians from beginning to end. It uses the mondrians textures indices, if provided to it.
            % If not, it creates them itself.
            
            import uri_classes.CFS_MOVERIO.CFS_Mondrian_texSeq_Factory; % I feel really stupid having to import this class into itself
            
            mondFreqInFrames = (CFS_seq_props.fps/CFS_seq_props.CFS_freq);
            numImagesNeeded = CFS_seq_props.CFS_freq*CFS_seq_props.totalTime/1000;
            frames = [1:mondFreqInFrames:numImagesNeeded*mondFreqInFrames];
            
            if(nargin<3)
                warning ('no texture indices supplied, creating textures from scratch');
                mondrianTexturesToUse = CFS_Mondrian_texSeq_Factory.createMondrianTextures(CFS_seq_props,PTB_window,numImagesNeeded);
            end
            if(nargin<4)
                warning('No fixation texture! Using first mondrian texture as fixation image!');
                fixationTexture = mondrianTexturesToUse(1);
            end
            
            [texturesIndices] = CFS_Mondrian_texSeq_Factory.createTexIndVec_fromExistingTexs(numImagesNeeded,mondrianTexturesToUse);
            
            textures_and_frames = [texturesIndices', frames'];
            
            % Now add the fixation:
            % calculate how many frames until fixation is over:
            numFixationFrames = CFS_seq_props.fps*CFS_seq_props.pretrialFixationDuration/1000;
            % offset created frame numbers by that number:
            textures_and_frames(:,2) = textures_and_frames(:,2)+numFixationFrames;
            textures_and_frames = [fixationTexture,1;textures_and_frames];
        end
        
        function [texturesIndices] = createMondrianTextures(CFS_seq_props,PTB_window,numImgs)
            import uri_classes.CFS_MOVERIO.Mondrian_Image_Factory;
            texturesIndices = zeros(1,numImgs);
            for iImg = 1:numImgs
                bitmap = Mondrian_Image_Factory.createMondrianImage(CFS_seq_props.mondriansProps);
                bitmap = uri_classes.CFS_MOVERIO.CFS_texSeq_Factory.addFusionFrameToBitmap(CFS_seq_props,bitmap);
                texturesIndices(iImg) = Screen('MakeTexture',PTB_window,bitmap);
            end
        end
        
        function outVec = createTexIndVec_fromExistingTexs(vecLength,texSet)
            % Uses texture IDs in "texSet" to create a vector the length of "vecLength", without any two
            % indices in the output vector containing the same image. Does so by shuffeling texSet anew on
            % every step and adding it to the end of the vector, only if the first entry of the addition is
            % different than the last entry of the existing vector.
            if(numel(unique(texSet))<numel(texSet))
                warning ('input variable texSet containes duplicates. The output will be made from unique(texSet).');
                texSet = unique(texSet);
            end
            
            steps = ceil(vecLength/numel(texSet));
            outVec = zeros(1,steps*numel(texSet));
            for iStep = 1:ceil(vecLength/numel(texSet))
                texSet = texSet(randperm(numel(texSet)));
                while (texSet(1) == outVec(max((iStep-1)*numel(texSet),1)))
                    texSet = texSet(randperm(numel(texSet)));
                end
                outVec((iStep-1)*numel(texSet)+1:(iStep)*numel(texSet)) = texSet;
            end
            
            outVec = outVec(1:vecLength);
        end
    end
    
end

