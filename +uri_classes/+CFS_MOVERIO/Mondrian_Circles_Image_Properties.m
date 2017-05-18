classdef Mondrian_Circles_Image_Properties < uri_classes.CFS_MOVERIO.Mondrian_Image_Properties
    %MONDRIAN_CIRCLES_IMAGE_PROPERTIES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        minRadius = 3; % of circle, in pixels
        maxRadius = 30; % of circle, in pixels
        circNum = 2500; % How many circles
    end
    
    methods
        function this = Mondrian_Circles_Image_Properties()
            this = this@uri_classes.CFS_MOVERIO.Mondrian_Image_Properties();
            this.addProps(...
                {'Mondrians_Num_Shapes','Mond_Min_Size','Mond_Max_Size'},...
                {'circNum','minRadius','maxRadius'}...
                )
        end
        
        function bitmap = createBitmap(this)
            
            circlesPositions = [this.canvasWidth*rand(this.circNum,1),...
                this.canvasHeight*rand(this.circNum,1),...
                (this.maxRadius-this.minRadius)*rand(this.circNum,1)+this.minRadius];
            circlesColors = repmat(this.palette,ceil(this.circNum/size(this.palette,1)),1);
            circlesColors = circlesColors(1:this.circNum,:);
            circlesColors = circlesColors(randperm(this.circNum),:);
            
            bitmap = ones(this.canvasHeight,this.canvasWidth,3);
            bitmap = insertShape(bitmap,'FilledCircle',circlesPositions,'Color',circlesColors,'Opacity',1,'SmoothEdges',false);
            bitmap = uint8(bitmap*255);
        end
        
    end
    
end

