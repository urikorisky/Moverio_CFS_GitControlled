% Test functionality of the whole experiment
path(path,'../');
sca; clear; clear import;
import uri_classes.common.* uri_classes.CFS_MOVERIO.*;

Experiment = Experiment_Presenter_CFS();
Experiment.initExperiment();