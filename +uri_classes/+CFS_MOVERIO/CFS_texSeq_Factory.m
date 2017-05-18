classdef CFS_texSeq_Factory < uri_classes.common.PTB_textureSeq_Factory
    %CFS_TEXSEQ_FACTORY 
    
    properties
    end
    
    methods (Static)
        
        function outBitmap = addFusionFrameToBitmap(CFS_seq_props,inBitmap)
            % Still not 100% implemented - the frame style could alter.
            % in MATLAB 2013 there's still no alpha channel control:
            hasOpacity = false;
            alphaChan = [];
            if (size(inBitmap,3)==4)
                alphaChan = inBitmap(:,:,4);
                inBitmap = inBitmap(:,:,1:3);
                hasOpacity = true;
            end
            outBitmap = inBitmap;
            if (verLessThan('matlab','8.6') || isempty(CFS_seq_props.frameBMP))
                % for MATLAB versions earlier than 2015b, no dashed lines
                % support:
                [outBitmap,alphaChan] = uri_classes.CFS_MOVERIO.CFS_texSeq_Factory.drawFusionLines_MatlabLessThan2015b(CFS_seq_props,outBitmap,hasOpacity,alphaChan);
            else
                [outBitmap,alphaChan] = uri_classes.CFS_MOVERIO.CFS_texSeq_Factory.drawFusionLines_Matlab2015bAndUp(CFS_seq_props.frameBMP,outBitmap,hasOpacity,alphaChan);
            end
            
            fixationBMP = uri_classes.CFS_MOVERIO.CFS_texSeq_Factory.getFixationBMP(CFS_seq_props);
            [outBitmap,alphaChan] = uri_classes.CFS_MOVERIO.CFS_texSeq_Factory.drawFusionLines_Matlab2015bAndUp(fixationBMP,outBitmap,hasOpacity,alphaChan);
%             frameLinesRects = [...
%                 [1, 1, CFS_seq_props.canvasWidth, CFS_seq_props.frameWidth];...
%                 [CFS_seq_props.canvasWidth-CFS_seq_props.frameWidth+1, 1, CFS_seq_props.frameWidth, CFS_seq_props.canvasHeight];...
%                 [1, CFS_seq_props.canvasHeight-CFS_seq_props.frameWidth+1, CFS_seq_props.canvasWidth, CFS_seq_props.frameWidth];...
%                 [1, 1, CFS_seq_props.frameWidth, CFS_seq_props.canvasHeight];...
%                 ]; % top;right;bottom;left
%             for iLine = 1:size(frameLinesRects,1)
%                 outBitmap = insertShape(outBitmap,'FilledRectangle',...
%                     frameLinesRects(iLine,:),...
%                     'Color',CFS_seq_props.frameCol,'Opacity',1);
%                 if (hasOpacity)
%                     alphaChan(frameLinesRects(iLine,2):frameLinesRects(iLine,2)+frameLinesRects(iLine,4)-1,...
%                         frameLinesRects(iLine,1):frameLinesRects(iLine,1)+frameLinesRects(iLine,3)-1) = 1;
%                 end
%             end
            if (hasOpacity)
                outBitmap(:,:,4) = alphaChan;
            end
        end

        function [outBitmap,alphaChan] = drawFusionLines_Matlab2015bAndUp(frameBMP,outBitmap,hasOpacity,alphaChan)
            frame_alphaChan = logical(frameBMP(:,:,4));
%             frame_alphaMap = repmat(frame_alphaChan,1,1,3);
%             outBitmap(frame_alphaMap) = frameBMP(frame_alphaMap);
            % ^ This method is terrible, reverting to old style:
            for iChan=1:3
                bmpInCurrChan = outBitmap(:,:,iChan);
                frmInCurrChan = frameBMP(:,:,iChan);
                bmpInCurrChan(frame_alphaChan) = frmInCurrChan(frame_alphaChan);
                outBitmap(:,:,iChan) = bmpInCurrChan;
            end
            if (hasOpacity)
                alphaChan(frame_alphaChan>0) = frame_alphaChan(frame_alphaChan>0)*255;
            end

        end
        
        function [outBitmap,alphaChan] = drawFusionLines_MatlabLessThan2015b(CFS_seq_props,outBitmap,hasOpacity,alphaChan)
            frameLinesRects = [...
                [1, 1, CFS_seq_props.canvasWidth, CFS_seq_props.frameWidth];...
                [CFS_seq_props.canvasWidth-CFS_seq_props.frameWidth+1, 1, CFS_seq_props.frameWidth, CFS_seq_props.canvasHeight];...
                [1, CFS_seq_props.canvasHeight-CFS_seq_props.frameWidth+1, CFS_seq_props.canvasWidth, CFS_seq_props.frameWidth];...
                [1, 1, CFS_seq_props.frameWidth, CFS_seq_props.canvasHeight];...
                ]; % top;right;bottom;left
            for iLine = 1:size(frameLinesRects,1)
                outBitmap = insertShape(outBitmap,'FilledRectangle',...
                    frameLinesRects(iLine,:),...
                    'Color',CFS_seq_props.frameCol,'Opacity',1);
                if (hasOpacity)
                    alphaChan(frameLinesRects(iLine,2):frameLinesRects(iLine,2)+frameLinesRects(iLine,4)-1,...
                        frameLinesRects(iLine,1):frameLinesRects(iLine,1)+frameLinesRects(iLine,3)-1) = 1;
                end
            end
        end
        
        function frameBMP = getFrameBMP(CFS_seq_props)
            frameRect = [0, 0, CFS_seq_props.canvasWidth, CFS_seq_props.canvasHeight];
            screenRectMinusMargins = get(0,'ScreenSize');
            screenRectMinusMargins(4) = screenRectMinusMargins(4)-100;
            screenRectMinusMargins(3) = screenRectMinusMargins(3)-100;
            [rectRatio,frameRect] = uri_classes.common.GraphicsMathUtils.fitRectInRectPow2(frameRect,screenRectMinusMargins);
            frameWidth = CFS_seq_props.frameWidth*rectRatio*2;
            h=figure('visible','off','Color','k','Position',frameRect,...
                'GraphicsSmoothing','off');
            rectangle('Position',frameRect,...
                'LineStyle','-','EdgeColor',[0 1 0.694],...
                'LineWidth',frameWidth,...
                'AlignVertexCenters','on');
            rectangle('Position',frameRect,...
                'LineStyle','--','EdgeColor',CFS_seq_props.frameCol,...
                'LineWidth',frameWidth,...
                'AlignVertexCenters','on');
            
            axis off;
            set(gca,'position',[0 0 1 1],'units','normalized')
            xlim(gca,[0 frameRect(3)])
            ylim(gca,[0 frameRect(4)])
            F = getframe(h);
            frameBMP = imresize(frame2im(F),1/rectRatio);
            close(h);
            
            alphaMap = max(frameBMP>0,[],3);
            frameBMP(:,:,4) = alphaMap*255;
            
        end
        
        function fixationBMP = getFixationBMP(CFS_seq_props)
            import uri_classes.CFS_MOVERIO.CFS_texSeq_Factory;
            strokeBMP = CFS_texSeq_Factory.createCrossBMP(...
                CFS_seq_props.fixationStrokeColor,...
                CFS_seq_props.fixationThickness+2,...
                CFS_seq_props.fixationArmLength+2,...
                CFS_seq_props.canvasHeight,...
                CFS_seq_props.canvasWidth);
            fixationBMP = CFS_texSeq_Factory.createCrossBMP(...
                CFS_seq_props.fixationColor,...
                CFS_seq_props.fixationThickness,...
                CFS_seq_props.fixationArmLength,...
                CFS_seq_props.canvasHeight,...
                CFS_seq_props.canvasWidth);
            fixationBMP = CFS_texSeq_Factory.overlayBitmaps(fixationBMP,strokeBMP);
            % for now, hard coded parameters:
%             fixationColor = CFS_seq_props.fixationColor;%[1 0 0];
%             lineThickness = CFS_seq_props.fixationThickness;%4;
%             armLength = CFS_seq_props.fixationArmLength;%10;
%             
%             height = CFS_seq_props.canvasHeight;
%             width = CFS_seq_props.canvasWidth;
% %             rect = [0, 0, width, height];
%             fixationBMP = zeros(height,width,4);
%             shape = zeros(height,width);
%             shape(round(height/2-lineThickness/2):round(height/2+lineThickness/2),...
%                 width/2-armLength:width/2+armLength) = 1;
%             shape(height/2-armLength:height/2+armLength,...
%                 round(width/2-lineThickness/2):round(width/2+lineThickness/2)) = 1;
%             for iCol=1:3
%                 fixationBMP(:,:,iCol)=fixationColor(iCol)*shape;
%             end
%             fixationBMP(:,:,4)=1*shape;
            % convert images to PTB-readable colors:
%             fixationBMP = fixationBMP*255;
            
        end
        
        function crossBMP = createCrossBMP(crossColor,crossThickness,crossArmLength,bmpHeight,bmpWidth)
            crossBMP = zeros(bmpHeight,bmpWidth,4);
            shape = zeros(bmpHeight,bmpWidth);
            shape(round(bmpHeight/2-crossThickness/2):round(bmpHeight/2+crossThickness/2),...
                bmpWidth/2-crossArmLength:bmpWidth/2+crossArmLength) = 1;
            shape(bmpHeight/2-crossArmLength:bmpHeight/2+crossArmLength,...
                round(bmpWidth/2-crossThickness/2):round(bmpWidth/2+crossThickness/2)) = 1;
            for iCol=1:3
                crossBMP(:,:,iCol)=crossColor(iCol)*shape;
            end
            crossBMP(:,:,4)=1*shape;%*255;
            % convert images to PTB-readable colors:
            crossBMP = crossBMP*255;            
        end
        
    end
    
end

