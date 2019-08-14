classdef EdcByLevelSetCreator < ElementalDensityCreator
    
    properties (Access = private)
       levelSet
       filterSettings
       levelSetSettings
    end
    
    methods (Access = public)
        
        function obj = EdcByLevelSetCreator(cParams)
            obj.filterSettings   = cParams.filterDataBase;
            obj.levelSetSettings = cParams.levelSetCreatorDataBase;
        end
        
        function createDensity(obj)
            obj.createLevelSet();
            obj.computeDensity();
        end        
       
        function ls = getLevelSet(obj)
            ls = obj.levelSet;
        end
        
        function f = getFieldsToPrint(obj)
            f{1} = obj.density();
            f{2} = obj.levelSet();
        end
    end
        
    methods (Access = private)
       
        function createLevelSet(obj)
           d = obj.levelSetSettings;             
           lsC = LevelSetCreator.create(d);
           obj.levelSet = lsC.getValue();             
        end
        
        function computeDensity(obj)
            lS = obj.levelSet;
            s = obj.filterSettings; 
            filter = FilterP0(lS,s);
            obj.density = filter.getDensity();            
        end
        
    end
    
    
end