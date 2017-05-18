fromScratch = 1;
path(path,'../');
if (fromScratch)
    
    sca; clear; clear import;
    import uri_classes.common.* uri_classes.CFS_MOVERIO.*;
    expView = Experiment_View_CFS();
    

    PTB_params = PTB_Interface_Params();
    PTB_params.debugLevel = PTB_Interface_Params.DEBUG_LEVEL_LOW;
%     PTB_params.screenNum = 0;

    expView.initGUI(PTB_params);

    expView.runFusionCalibration(40);


    % set mondrian properties:
    mondrianProps = Mondrian_Circles_Image_Properties();
    mondrianProps.canvasWidth = expView.winWidth;
    mondrianProps.canvasHeight = expView.winHeight;
%     mondrianProps.canvasWidth = 1920/2;
%     mondrianProps.canvasHeight = 1080;
    % set CFS sequence properties:
    cfsTexSeqProps = CFS_texSeq_Properties();
    cfsTexSeqProps_props = cfsTexSeqProps.getProps();
    cfsTexSeqProps_props.Mondrian_Props = mondrianProps;
    cfsTexSeqProps_props.Time_To_Start_Fade = 500;
    cfsTexSeqProps_props.Fade_Duration = 1000;
    cfsTexSeqProps.setProps(cfsTexSeqProps_props);    


    cfsTexSeqProps.frameBMP = CFS_texSeq_Factory.getFrameBMP(cfsTexSeqProps);
    cfs_texturesIndices = CFS_Mondrian_texSeq_Factory.createMondrianTextures(cfsTexSeqProps,expView.ptb_window,100);
end
cfs_TexSeq = CFS_Mondrian_texSeq_Factory.createSeq(cfsTexSeqProps,expView.ptb_window,cfs_texturesIndices);

ovrly_TexSeq = CFS_Overlay_texSeq_Factory.createSeq(cfsTexSeqProps,expView.ptb_window);

expView.displayTexturesSequence_NoResponse(cfs_TexSeq,ovrly_TexSeq);
% expView.displayTexturesSequence_NoResponse(ovrly_TexSeq,cfs_TexSeq);