classdef ElementalDensityCreator < handle
       
   properties (Access = protected)
       density       
   end
   
   methods (Access = public, Static)
       
       function obj = create(cParams)
          f = ElementalDensityCreatorFactory();
          obj = f.create(cParams);            
       end       
       
   end 
   
   methods (Access = public)
       
       function dC = getDensityCreator(obj)
           dC = obj.densityCreator;
       end
       
       function d = getDensity(obj)
           d = obj.density;
       end    
       
       function f = getFieldsToPrint(obj)
           f{1} = obj.density;
       end
            
   end
    
   methods (Access = public, Abstract)
       createDensity(obj)
   end
    
end