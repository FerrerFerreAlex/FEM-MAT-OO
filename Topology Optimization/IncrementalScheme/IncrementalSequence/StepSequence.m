classdef StepSequence < IncrementalSequence
    
    methods (Access = public)
       
        function obj = StepSequence(nSteps,a0,a1)
            obj.nSteps = nSteps;
            obj.initialValue = a0;
            obj.finalValue = a1;
            obj.generateAlphaSequence();
        end         
        
        function update(obj,i)
            obj.value = obj.alpha(i);
        end
        
    end
    
    methods (Access = protected)
        
        function generateAlphaSequence(obj)
            a0 = log2(obj.initialValue);
            a1 = log2(obj.finalValue);
            n  = obj.nSteps;
            obj.alpha = 2.^round(linspace(a0,a1,n));
        end
        
    end
    
end