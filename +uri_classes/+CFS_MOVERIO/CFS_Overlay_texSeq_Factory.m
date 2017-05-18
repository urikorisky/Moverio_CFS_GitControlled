classdef CFS_Overlay_texSeq_Factory < uri_classes.CFS_MOVERIO.CFS_texSeq_Factory
    %CFS_OVERLAY_TEXSEQ_FACTORY Creates a sequence of overlay PTB textures and their display times,
    % to use in a CSF paradigm. The overlay is supposed to fade slowly.
    
    properties
    end
    
    methods (Static)
        
        function [textures_and_frames] = createSeq(CFS_seq_props,PTB_window,overlayTexturesToUse)
            % The first texture is the full-alpha overlay (in its maximum alpha, not necessarily 1), and
            % should be on the first frame (change this to be a parameter!).
            
            if(nargin<3)
                warning ('no overlay texture indices supplied, creating overlay textures from scratch');
                import uri_classes.CFS_MOVERIO.CFS_Overlay_texSeq_Factory;
                overlayTexturesToUse = CFS_Overlay_texSeq_Factory.createOverlayFadeTextures(CFS_seq_props,PTB_window);
            end
            
            frames = [CFS_seq_props.timeToStartFade/1000*CFS_seq_props.fps:...
                (CFS_seq_props.timeToStartFade+CFS_seq_props.timeToEndFade)/1000*CFS_seq_props.fps-1];
            
            textures_and_frames = [overlayTexturesToUse', frames'];
            
            % Now add the fixation:
            % calculate how many frames until fixation is over:
            numFixationFrames = CFS_seq_props.fps*CFS_seq_props.pretrialFixationDuration/1000;
            % offset created frame numbers by that number:
            textures_and_frames(:,2) = textures_and_frames(:,2)+numFixationFrames;
            textures_and_frames = [overlayTexturesToUse(1),1;textures_and_frames];            
        end
        
        function [texturesIndices] = createOverlayFadeTextures(CFSTexSeqProperties,PTB_window)
            % length of fade is CFSTexSeqProperties.timeToEndFade, and the number of steps needed is:
            numImagesNeeded = ceil(CFSTexSeqProperties.timeToEndFade/1000*CFSTexSeqProperties.fps);
            texturesIndices = zeros(1,numImagesNeeded);
            overlayCol = CFSTexSeqProperties.overlayColor;
            colorBlock = ones(CFSTexSeqProperties.canvasHeight,CFSTexSeqProperties.canvasWidth,4);
            for iRGBel = 1:3
                colorBlock(:,:,iRGBel) = colorBlock(:,:,iRGBel)*overlayCol(iRGBel);
            end
            alphaChannel = ones(CFSTexSeqProperties.canvasHeight,CFSTexSeqProperties.canvasWidth);
            alphaVals = linspace(CFSTexSeqProperties.overlayStartAlpha,CFSTexSeqProperties.overlayFinalAlpha,numImagesNeeded);
            for iImg = 1:numImagesNeeded
                currImg = colorBlock;
                currImg(:,:,4) = alphaChannel*alphaVals(iImg)*255;
                currImg = uint8(currImg);
                currImg = uri_classes.CFS_MOVERIO.CFS_texSeq_Factory.addFusionFrameToBitmap(CFSTexSeqProperties,currImg);
                texturesIndices(iImg) = Screen('MakeTexture',PTB_window,currImg);
%                 Screen('DrawTexture',PTB_window,texturesIndices(iImg));
%                 Screen('Flip',PTB_window); pause(0.5);
            end
        end
        
    end
    
end

