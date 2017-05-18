clear; clear import;
import uri_classes.common.*;

a = Experiment_Plan_Factory;

a.addCondition('cond1',{'a','b'},[1 2])
a.addCondition('cond2',{'a','b'},[1 1])
a.addConstraint([1,2],2);
% a.addConstraint(2,4);
% a.addConstraint(1,10);

condsCount = a.getCondsLevelsCount(120);

% [order,status] = a.findConstrainedOrder(120,[],condsCount,10);

% [order, updatedCondsCount]=a.createOrder(120,condsCount);
% 
% a.validateOrder(order);