classdef ParametersVademecumCreator < handle
    
    properties (Access = public)
        params
    end
    
    properties (Access = private)
        mx
        my
        phi
        q
    end
    
    methods (Access = public)
        
        
        function obj = ParametersVademecumCreator(cParams)
            obj.init(cParams)
            obj.createMx();
            obj.createMy();
            obj.createPhi();
            obj.createQ();
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.mx  = cParams.mx;
            obj.my  = cParams.my;
            obj.phi = cParams.phi;
            obj.q   = cParams.q;            
        end
                
        function createMx(obj)
            v = obj.mx.values;
            obj.params.mx = obj.createLinearParameter(v);
        end
        
        function createMy(obj)
            v = obj.my.values;
            obj.params.my = obj.createLinearParameter(v);            
        end
        
        function createPhi(obj)
            v = obj.phi.values;
            obj.params.phi = obj.createLinearParameter(v);            
        end
        
        function createQ(obj)
            v    = obj.q.values;
            expo = obj.q.expo;
            obj.params.q = obj.createExponentialParameter(v,expo);
        end
        
        function vs = createExponentialParameter(obj,v,expo)
            vs = obj.createParameter(v);
            vs.values = obj.createExponentialDiscretization(vs,expo);
        end
        
        function vs = createLinearParameter(obj,v)
            vs = obj.createParameter(v);
            vs.values = obj.createLinearDiscretization(vs);
        end
        
    end
    
    methods (Access = private, Static)
        
        function vs = createParameter(v)
            vs.min = v(1);
            vs.max = v(2);
            vs.n   = v(3);
        end
        
        function val = createLinearDiscretization(v)
            val = linspace(v.min,v.max,v.n);
        end
        
        function val = createExponentialDiscretization(v,expo)
            val = expo.^linspace(v.min,v.max,v.n);
        end
        
    end    
    
end