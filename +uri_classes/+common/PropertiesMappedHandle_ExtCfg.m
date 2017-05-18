classdef PropertiesMappedHandle_ExtCfg < uri_classes.common.PropertiesMappedHandle & dynamicprops
    %PropertiesMappedHandle_ExtCfg A "propertiesMappedHandle" which can be mapped using an XLSX
    %file. 
    
    properties
        rawPropsFile @cell;
        propsInternalNames @cell;
    end
    
    methods
        
        
        function setPropsNamesAndVariablesFromList(this,extNames,intNames,types,vals)
            % all inputs are cell arrays
            if (isempty(extNames))
                extNames = intNames;
            end
            for iProp = 1:numel(intNames)
                this.propsInternalNames{iProp} = intNames{iProp};
                propMeta=this.addprop(this.propsInternalNames{iProp});
%                 propMeta.Access = 'protected';
                currVal = [];
                switch (types{iProp})
                    case 'double'
                        if (isnumeric(vals{iProp}))
                        % if it's a single scalar, don't convert to a
                        % matrix:
                            currVal = vals{iProp};
                        else
                        % otherwise, do convert:
                            currVal = str2num(vals{iProp});
                        end
                    case 'logical'
                        if (isnumeric(vals{iProp}))
                        % if it's a single scalar, don't convert to a
                        % matrix:
                            currVal = logical(vals{iProp});
                        else
                        % otherwise, do convert:
                            currVal = logical(str2num(vals{iProp}));
                        end
                    case 'char'
                        currVal = vals{iProp};
                    case 'cell'
                        % This is only a cell of strings, comma-delimited!
                        currVal = strsplit(vals{iProp},',');
                    otherwise
                        % We shouldn't get here, but in this case just take
                        % whatever you can:
                        currVal = vals{iProp};
                end
                this.(this.propsInternalNames{iProp}) = currVal;
                this.mapSingleProp(extNames{iProp},this.propsInternalNames{iProp})
            end
            
        end
        
        function setPropsMetaDataFromList(this,ext_names,metaDataFields,metaDataValues)
            for iProp = 1:numel(ext_names)
                fieldsAndNames = [metaDataFields' metaDataValues(iProp,:)']';
                metaDataObj = struct(fieldsAndNames{:});
                this.mapSingleProp_MetaData(ext_names{iProp},metaDataObj)
            end
        end
        
    end
    
end

