clear all;
clear import;
import uri_classes.common.* uri_classes.CFS_MOVERIO.*;

model = uri_classes.CFS_MOVERIO.Experiment_Model_CFS;

model.setCurrentSubjID(100);
model.retrieveSubjectPlanFiles(model.subjID);