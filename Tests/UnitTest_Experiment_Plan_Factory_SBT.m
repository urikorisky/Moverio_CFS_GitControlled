clear;
clear import;
import uri_classes.common.*;

factory = Experiment_Plan_Factory_SessBlockTrial;

props = factory.getProps;
props.Blocks_Per_Session = [1];
props.Trials_Per_Block = [150];
props.Number_Of_Sessions = 1;
factory.setProps(props);
clear props

factory.addCondition('cond1',{'a','b','c'},[1 1 1])
% factory.addCondition('cond2',{'a','b'},[1 1])
% factory.addConstraint([1,2],2);
factory.addConstraint(1,5);

timeline = factory.produceExperimentTimeline();

timelineInfo = timeline.exportInfo;

% timeline_clone = factory.importExperimentTimeline(timelineInfo);