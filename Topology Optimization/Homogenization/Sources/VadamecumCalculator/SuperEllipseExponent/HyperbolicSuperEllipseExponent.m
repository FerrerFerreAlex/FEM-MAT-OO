classdef HyperbolicSuperEllipseExponent < SuperEllipseExponent
    
   properties (Access = private)
       alpha
       beta
       gamma
   end
    
   methods (Access = public)
       
       function obj = HyperbolicSuperEllipseExponent(cParams)
            obj.init(cParams)
       end
       
       function q = computeValue(obj,mx,my)
            a = obj.alpha;
            b = obj.beta;
            c = obj.gamma;
            x = max(mx,my);
            q = min(512,c*(1/(1-x^b))^a); 
       end
           
   end
   
   methods (Access = private)
       
       function init(obj,cParams)
            obj.mx = cParams.mx;
            obj.my = cParams.mx;
            obj.alpha = cParams.alpha;
            obj.beta  = cParams.beta;
            obj.gamma = cParams.gamma; 
       end

   end
   
end