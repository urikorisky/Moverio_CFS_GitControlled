classdef PropertiesMappedHandle < handle
    %PROPERTIESMAPPEDVALUE An extension of MATLAB's "handle" class, which allows getting and setting accessible
    % properties of the class in one-shot, using a containers.Map object.
    %   Each property can also be further validated using a getter\setter
    
    properties
        propsMap = containers.Map();
        propsMeta_Map = containers.Map();
    end
    
    methods

        function createPropsMap(this,propsPublicNames,propsPrivateNames)
            this.propsMap = containers.Map(propsPublicNames,propsPrivateNames);
        end
        
        function addProps(this,propsPublicNames,propsPrivateNames)
            pubNamesNow = keys(this.propsMap);
            prvtNamesNow = values(this.propsMap);
            this.createPropsMap([propsPublicNames pubNamesNow],[propsPrivateNames prvtNamesNow]);
        end
        
        function createPropsMetaDataMap(this,propsPublicNames,propsMetaData)
            this.propsMeta_Map = containers.Map(propsPublicNames,propsMetaData);
        end
        
        function mapSingleProp(this,propPublicName,propPrivateName)
            currKeys = this.propsMap.keys;
            currVals = this.propsMap.values;
            currKeys{end+1} = propPublicName;
            currVals{end+1} = propPrivateName;
            this.createPropsMap(currKeys,currVals);
        end
        
        function mapSingleProp_MetaData(this,propPublicName,propMetaData)
            currKeys = this.propsMeta_Map.keys;
            currVals = this.propsMeta_Map.values;
            currKeys{end+1} = propPublicName;
            currVals{end+1} = propMetaData;
            this.createPropsMetaDataMap(currKeys,currVals);
        end
        
        function [props, propsMetaData] = getProps(this)
            if (isempty(this.propsMap.keys))
                warning('Class %s does not specify a properties map, or specifies an empty map.',class(this));
            end
            % Export the properties themselves:
            keys = this.propsMap.keys;
            props = struct();
            for iProp = 1:this.propsMap.length
                props.(keys{iProp}) = this.(this.propsMap(keys{iProp}));
            end
            
            % Export the properties' metadata:
            keys = this.propsMeta_Map.keys;
            propsMetaData = struct();
            for iProp = 1:this.propsMeta_Map.length
                propsMetaData.(keys{iProp}) = this.propsMeta_Map(keys{iProp});
            end           
        end
        
        function setProps(this,props)
            propNames = fields(props);
            for iProp = 1:numel(propNames)
                try
                    this.(this.propsMap(propNames{iProp})) = props.(propNames{iProp});
                catch err
                    % assuming user tried to set a property that doesn't
                    % exist in this class's map
%                     warning('Property %s doesn''t exist in %s',propNames{iProp},class(this));
                end
            end
        end
      
    end
    
end

