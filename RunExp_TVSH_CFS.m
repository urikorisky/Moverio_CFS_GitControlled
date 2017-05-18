bps = dbstatus;
save('breakpoints.mat','bps');
clear classes;

% clear;
sca;
% clear import; clear KbWait;
delete(timerfindall);
import uri_classes.common.* uri_classes.CFS_MOVERIO.*;
addpath(genpath('./externalFuncsInclude/'));

load('breakpoints.mat');
dbstop(bps);

experiment = uri_classes.CFS_MOVERIO.Experiment_Presenter_CFS;
experiment.initExperiment;