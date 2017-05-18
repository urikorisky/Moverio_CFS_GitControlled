classdef CFS_texSeq_Properties < uri_classes.common.PTB_textureSeq_Properties
    %CFS_TEXSEQ_PROPERTIES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        CFS_freq = 10; % in Hz, how many times the mondrians change in a second.
        timeToStartFade = 0; % in ms, how long till the blocking of the view starts to fade
        timeToEndFade = 1000; % in ms from timeToStartFade, how long till the blocking of the view fades completely
        totalTime = 10000; % in ms, length of sequence
        overlayFinalAlpha = 0; % from 0 to 1
        overlayStartAlpha = 1; % from 0 to 1
        overlayColor = [1 1 1]*255; % rgb
        mondriansProps @uri_classes.CFS_MOVERIO.Mondrian_Image_Properties;
        
        frameWidth = 10;
        frameCol = [1,0,0]; % leave this normalized to 1!
        frameStyle = 'Solid'; % or "dashed"\"dashedBW"
        
        frameBMP = []; %insert here frame BMP for pre-drawing and later suprimposing on the mondrians
        
        numImages = 100; % Number of different mondrians that should be produced.
        
        fixationColor = [1 0 0];
        fixationThickness = 4;
        fixationArmLength = 10;
        fixationStrokeColor = [0 0 1];
        pretrialFixationDuration = 1000;
    end
    
    methods
        function this = CFS_texSeq_Properties()
            this.propsMap = containers.Map({'Mondrian_Props',...
                'CFS_Frequency',...
                'CFS_Overlay_Fade_Start',...
                'CFS_Overlay_Fade_Duration',...
                'CFS_Overlay_Start_Contrast',...
                'CFS_Overlay_End_Contrast',...
                'CFS_Duration',...
                'Mondrian_Frame_Type',...
                'CFS_Number_Of_Different_Images',...
                'Fixation_Color',...
                'Fixation_Thickness',...
                'Fixation_Arm_Length',...
                'Fixation_Stroke_Color',...
                'Pre_Trial_Fixation_Duration'...
                },...
                {'mondriansProps','CFS_freq','timeToStartFade','timeToEndFade',...
                'overlayStartAlpha','overlayFinalAlpha','totalTime','frameStyle',...
                'numImages','fixationColor','fixationThickness','fixationArmLength',...
                'fixationStrokeColor','pretrialFixationDuration'}); %TODO: complete list. DO NOT include width or height.
            this.fps = 60;
            this.canvasWidth = 480;
            this.canvasHeight = 540;
            this.mondriansProps = uri_classes.CFS_MOVERIO.Mondrian_Circles_Image_Properties();
            this.mondriansProps.canvasWidth = this.canvasWidth;
            this.mondriansProps.canvasHeight = this.canvasHeight;
        end
        
        function this = set.mondriansProps(this,newMondProps)
            if (~isa(newMondProps,'uri_classes.CFS_MOVERIO.Mondrian_Image_Properties'))
                error ('Input properties not matching type. Should be of type "Mondrian_Image_Properties"');
            end
            this.mondriansProps = newMondProps;
            this.canvasWidth = this.mondriansProps.canvasWidth;
            this.canvasHeight = this.mondriansProps.canvasHeight;
        end
        
    end
    
end

