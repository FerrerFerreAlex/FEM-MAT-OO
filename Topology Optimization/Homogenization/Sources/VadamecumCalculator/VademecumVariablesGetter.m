classdef VademecumVariablesGetter < handle
    
    properties (Access = private)
        variables
        homogenizer
    end
    
    methods (Access = public)
        
        function obj = VademecumVariablesGetter(cParams)
            obj.homogenizer = cParams.homogenizer;
        end
        
        function v = get(obj)
            obj.obtainHomogenizerData();
            v = obj.variables;
        end
        
    end
    
    methods (Access = private)
        
        function obtainHomogenizerData(obj)
            obj.obtainComputedCellVariables();
            obj.obtainIntegrationVariables();
        end
        
        function obtainComputedCellVariables(obj)
            obj.obtainVolume();
            obj.obtainCtensor();
            obj.obtainStressesAndStrain();
            obj.obtainDisplacements();
        end
        
        function obtainVolume(obj)
            v = obj.homogenizer.integrationVar.geoVol;
            obj.variables.volume = v;
        end
        
        function obtainCtensor(obj)
            Ch = obj.homogenizer.cellVariables.Ch;
            obj.variables.Ctensor = Ch;
        end
        
        function obtainStressesAndStrain(obj)
            stress = obj.homogenizer.cellVariables.tstress;
            strain = obj.homogenizer.cellVariables.tstrain;
            obj.variables.tstress = stress;
            obj.variables.tstrain = strain;
        end
        
        function obtainDisplacements(obj)
            displ = obj.homogenizer.cellVariables.displ;
            obj.variables.displ = displ;
        end
        
        function obtainIntegrationVariables(obj)
            intVar = obj.homogenizer.integrationVar;
            obj.variables.integrationVar = intVar;
        end

    end
    
end