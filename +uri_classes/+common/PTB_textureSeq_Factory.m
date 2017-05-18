classdef (Abstract) PTB_textureSeq_Factory < handle
    %PTB_TEXTURESEQ_FACTORY Creates a sequence of textures IDs and timings to present them.
    %   The textures are created by this class, and the timings as well, by properties it receives from its
    %   parent.
    % This class is ABSTRACT.
    
    properties
    end
    
    methods
        
        function [textures_and_frames] = createSeq(textureSeqProps,PTB_screen)
            % returns an Mx2 matrix, first column is texture PTB ID, second is frame number from beginning of
            % sequence. textureSeqProps is an object of type PTB_textureSeq_Properties.
            
        end
    end   
    
    methods (Static)
        function bmp = overlayBitmaps(bmpOver,bmpUnder)
            if (size(bmpOver,3)<4)
                error('Can''t overlay a BMP with no alpha channel!');
            end
            bmp = bmpUnder;
            alphaChan = bmpOver(:,:,4);
            for iCol=1:3
                bmp(:,:,iCol) = bmp(:,:,iCol).*(1-alphaChan)+bmpOver(:,:,iCol).*alphaChan;
            end
            bmp(:,:,4) = min(bmpOver(:,:,4)+bmpUnder(:,:,4),255);
        end
        
    end
    
end

