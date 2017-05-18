clear all;
clear import;
import uri_classes.common.* uri_classes.CFS_MOVERIO.*;

dm = uri_classes.CFS_MOVERIO.ExperimentDataManager_CFS();

dm.logManager.createLogDir('testLogs','./testLogs');

[subjData,subjExpTimeline,subjExpParams] = dm.retrieveSubjectData(100);

