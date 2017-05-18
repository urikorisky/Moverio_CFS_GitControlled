classdef clonableMap < containers.Map
    
    properties
        
    end
    
    methods
        function this=clonableMap(keys,values)
            this = this@containers.Map(keys,values);
        end
        
        function newCopy=clone(this)
            newCopy = containers.Map(this.keys,this.values);
        end
        
    end
    
end