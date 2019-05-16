classdef Optimizer_PG < Optimizer_Unconstrained
    
    properties  (GetAccess = public, SetAccess = private)
        optimality_tol
    end
    
    properties (GetAccess = public, SetAccess = protected)
        type = 'PROJECTED GRADIENT'
    end
    
    properties (Access = private)
       upperBound
       lowerBound
    end
    
    methods (Access = public)
        
        function obj = Optimizer_PG(cParams)
            obj@Optimizer_Unconstrained(cParams);
            obj.upperBound = cParams.ub;
            obj.lowerBound = cParams.lb;            
        end
        
        function x_new = compute(obj)
            x_n      = obj.designVariable.value;
            gradient = obj.objectiveFunction.gradient;            
            x_new = x_n-obj.lineSearch.kappa*gradient;
            ub = obj.upperBound*ones(length(x_n(:,1)),1);
            lb = obj.lowerBound*ones(length(x_n(:,1)),1);
            x_new = max(min(x_new,ub),lb);
            obj.designVariable.value = x_new;
            l2Norm = obj.designVariable.computeL2normIncrement();
            obj.opt_cond = sqrt(l2Norm);
        end
        
    end
    
end