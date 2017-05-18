clear classes; sca;
clear import;
delete(timerfindall);
import uri_classes.common.* uri_classes.CFS_MOVERIO.*;
addpath('../externalFuncsInclude/');

presenter = uri_classes.CFS_MOVERIO.Experiment_Presenter_CFS;
presenter.initExperiment;
% disp('assets preparation done');
% pause();
% 
% presenter.View.prepareCFStrial(presenter.View.cfsProps)
% 
% disp('trial preparation done');
% pause();
% 
% [keysPressed, firstPressTimes, startTime, endTime, duration] = presenter.View.showCFStrial();