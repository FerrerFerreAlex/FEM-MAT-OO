classdef OneTetrahedronRandCoordOrderedConnecCase1 <  VectorizedTriangulationTest
    
    properties (Access = private)
       testName = 'OneTetrahedronRandCoordOrderedConnecCase1';        
    end
    
    methods (Access = protected)
        
        function createCoordAndConnec(obj)
            obj.coord = rand(4,3);            
            obj.connec = [1 2 3 4];
        end
        
        function createLevelSet(obj)
             obj.levelSet = [-7.8496;9.7731;8.3404;8.3622];
        end        
        
    end
    
end