classdef ConstantSuperEllipseExponent < SuperEllipseExponent
    
   properties (Access = private)
       value
   end
    
   methods (Access = public)
       
       function obj = ConstantSuperEllipseExponent(cParams)
            obj.value = cParams.value;
       end
    
       function q = computeValue(obj,mx,my)
          q = obj.value; 
       end
       
   end
   
end