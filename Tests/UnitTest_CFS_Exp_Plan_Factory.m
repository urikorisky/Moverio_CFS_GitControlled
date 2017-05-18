clear all;
clear import;
import uri_classes.common.* uri_classes.CFS_MOVERIO.*;

factory = CFS_Experiment_Plan_Factory;

model = Experiment_Model_CFS;
model.setExperimentParametersFromFile('../Stim/CFS_defaultParams.xlsx');

factory.setCFSexperimentParams(model.DataManager.experimentParameters.getProps)

timeline = factory.produceExperimentTimeline;
