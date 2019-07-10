classdef TopOptTests < testRunner
    
    properties (Access = protected)
        FieldOfStudy = 'Topology Optimization'
        tests
    end
    
    methods (Access = public)
        
        function obj = TopOptTests()
            obj@testRunner();
        end
        
    end
    
    methods (Access = protected)
        
        function loadTests(obj)
            obj.tests = {...    
                'testDualNestedInPrimalWithProjectedGradient';                
                'testStressM1M2';      
                'testM1M2';                  
                'testInteriorPerimeter';
                'testCantilever2';
                'testMicro';                
                'testCantilever3';
                'testBridge';
                'testCantilever';
                'testBridge2';
                'testDualNestedInPrimalWithSlerp';
                'testGripping';
                'testMicro2';              
                };
        end
        
    end
    
end
