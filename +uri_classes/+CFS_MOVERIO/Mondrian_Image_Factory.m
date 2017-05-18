classdef Mondrian_Image_Factory
    %MONADRIAN_IMAGE_FACTORY Creates an image of mondrians according to specified attributes
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods (Static)
        function bitmap = createMondrianImage(varargin)
            import uri_classes.CFS_MOVERIO.Mondrian_Image_Properties;
            if (nargin==1) 
                mondrian_props = varargin{1};
                if (~isa(mondrian_props,'uri_classes.CFS_MOVERIO.Mondrian_Image_Properties'))
                    error ('Input properties not matching type. Should be of type "Mondrian_Image_Properties"');
                end
            else
                warning('No properties given to Mondrian_Image_Factory.createMondrianImage(). Creating a default circles-Mondrian image.');
                mondrian_props = Mondrian__Circles_Image_Properties();
            end

            bitmap = mondrian_props.createBitmap();
        end
    end
    
end

