classdef Density < DesignVariable
    
    methods (Access = public)
        
        function obj = Density(cParams)
            obj.init(cParams);
        end
        
        function update(obj,value)
            obj.value = value;
        end
        
    end
    
    methods (Access = private)
        
    end
    
end

