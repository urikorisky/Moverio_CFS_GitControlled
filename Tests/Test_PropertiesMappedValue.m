classdef Test_PropertiesMappedValue < uri_classes.common.PropertiesMappedValue
    %TEST_PROPERTIESMAPPEDVALUE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        prop1 @double;
        prop2 @double;
    end
    
    methods
        
        function this = Test_PropertiesMappedValue()
            this.propsMap = containers.Map({'PROP_1','PROP_2'},{'prop1','prop2'});
        end
        
    end
    
end

