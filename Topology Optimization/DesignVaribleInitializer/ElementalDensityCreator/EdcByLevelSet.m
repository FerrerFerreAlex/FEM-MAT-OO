classdef EdcByLevelSet < ElementalDensityCreator
    
    properties (Access = private)
       levelSet
       filterSettings
    end
    
    methods (Access = public)
        
        function obj = EdcByLevelSetCreator(cParams)
            obj.filterSettings   = cParams.filterDataBase;
            obj.levelSet         = cParams.levelSetCreatorDataBase;
        end        
       
        function ls = getLevelSet(obj)
            ls = obj.levelSet;
        end
        
        function createDensity(obj)
            obj.computeDensity();
        end       
        
    end
    
    methods (Access = private)
              
        function computeDensity(obj)
            lS = obj.levelSet;
            d  = obj.filterSettings; 
            filter = FilterP0(lS,d);
            obj.density = filter.getDensity();            
        end
        
    end
    
end