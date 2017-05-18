clear;
clear import;
import uri_classes.common.*;

timeline = Test_ExperimentTimeline();

for i=1:3
    timeline.insertStep([]);
end

timeline.start();