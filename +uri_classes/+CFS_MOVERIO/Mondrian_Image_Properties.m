classdef Mondrian_Image_Properties < uri_classes.common.PropertiesMappedHandle
    %MONDRIAN_IMAGE_PROPERTIES Contains properties for creation of a Mondrian image
    %   Detailed explanation goes here
    
    properties (Constant)
       PALETTE_GRAYSCALE = [.1 .1 .1; .2 .2 .2; .3 .3 .3; .4 .4 .4; .5 .5 .5; .6 .6 .6; .7 .7 .7; .8 .8 .8; .9 .9 .9];
       PALETTE_COLOR_BASIC = [0 0 1; 0 1 0; 0 1 1; 1 0 0; 1 0 1; 1 1 0]*255; % no black - black is transparent! Also removed white, the background will be white anyway
    end
    
    properties
        palette @double;
        canvasWidth = 480; % in pixels
        canvasHeight = 540; % in pixels
    end
    
    methods
        
        function this = Mondrian_Image_Properties()
            % set default values:
            this.palette = this.PALETTE_COLOR_BASIC;
            this.createPropsMap({'Mondrians_Colors'},...
                {'palette'});
        end
        
        function bitmap = createBitmap()
        end
        
    end
    
end

