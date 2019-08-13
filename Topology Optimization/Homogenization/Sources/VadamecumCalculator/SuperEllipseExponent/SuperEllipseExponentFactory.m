classdef SuperEllipseExponentFactory < handle
    
   methods (Access = public, Static)
       
       function obj = create(cParams)
           switch cParams.type
               case 'Constant'
                   obj = ConstantSuperEllipseExponent(cParams);
               case 'Hyperbolic'
                   obj = HyperbolicSuperEllipseExponent(cParams);                                      
           end
       end
    
   end
  
    
    
end
    