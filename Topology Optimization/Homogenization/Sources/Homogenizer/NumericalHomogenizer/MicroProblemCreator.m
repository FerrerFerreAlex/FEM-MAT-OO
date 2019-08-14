classdef MicroProblemCreator < handle
    
    properties (Access = public)
        microProblem
        density
        elemDensCreator
        matValues        
    end
    
    properties (Access = private)
        fileName
        pdim               
        settings
        materialProperties
        interpolation
    end    
    
    methods (Access = public)
        
        function obj = MicroProblemCreator(cParams)
            obj.init(cParams)      
        end
        
        function create(obj)
            obj.buildMicroProblem();
            obj.createInterpolation();
            obj.createElementalDensityCreator();
            obj.obtainDensity();
            obj.createMaterialProperties()
            obj.setMaterialPropertiesInMicroProblem()                  
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.fileName = cParams.fileName;
            obj.pdim     = cParams.pdim;    
            obj.settings = cParams.settings;
        end
        
        function buildMicroProblem(obj)
            obj.microProblem = Elastic_Problem_Micro(obj.fileName);
            obj.microProblem.preProcess();
        end
        
        function createInterpolation(obj)
            d.interpolation           = obj.settings.interpolation.materialInterpolation;
            d.constitutiveProperties  = obj.settings.materialInterpolation.matProp;
            d.typeOfMaterial          = obj.settings.materialInterpolation.materialType;
            d.dim                     = obj.pdim;
            interp  = Material_Interpolation.create(d);
            obj.interpolation = interp;
            obj.matValues = d.constitutiveProperties;
        end
        
        function createElementalDensityCreator(obj)
            cParams      = obj.createElementalDensityCreatorSettings();
            cParams.type = obj.settings.elementDensityCreator;
            edc     = ElementalDensityCreator.create(cParams);
            edc.createDensity();
            obj.elemDensCreator = edc;
        end
        
        function d = createElementalDensityCreatorSettings(obj)
            sLevelSet = obj.createLevelSetCreatorSettings();
            sFilter   = obj.createFilterSettings();
            d.levelSetCreatorDataBase = sLevelSet;
            d.filterDataBase = sFilter;
        end
        
        function obtainDensity(obj)
            obj.density = obj.elemDensCreator.getDensity();
        end
        
        function createMaterialProperties(obj)
            d = obj.density;
            obj.materialProperties = obj.interpolation.computeMatProp(d);
        end
        
        function setMaterialPropertiesInMicroProblem(obj)
            m = obj.materialProperties;
            obj.microProblem.setMatProps(m);
        end
        
        function d = createLevelSetCreatorSettings(obj)
            d = obj.settings.levelSet;
            d.ndim  = obj.microProblem.mesh.ndim;
            d.coord = obj.microProblem.mesh.coord;
        end
        
        function d = createFilterSettings(obj)
            d.shape = obj.microProblem.element.interpolation_u.shape;
            d.conec = obj.microProblem.geometry.interpolation.T;
            d.quadr = obj.microProblem.element.quadrature;
        end
        
    end
    
    
end