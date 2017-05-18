clear;
clear import;
import uri_classes.common.*;

session = Experiment_Timeline_Session();
block = Experiment_Timeline_Block();
trial = Experiment_Timeline_Trial();

block.addTrial_ByObject(trial);

session.addBlock_ByObject(block);