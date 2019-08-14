classdef NumericalHomogenizerDataBase < handle
    
    properties (SetAccess = private, GetAccess = public)
        dataBase
    end
    
    properties (Access = private)
        femFileName
        pdim
        elementDensityCreatorType
    end
    
    methods (Access = public)
        
        function obj = NumericalHomogenizerDataBase(femFileName)
            obj.init(femFileName)
            obj.createMicroProblemCreatorSettings();
            obj.createDataBase();
        end
        
    end
    
    
    methods (Access = private)
        
        function init(obj,femFileName)
            obj.femFileName = femFileName;
            obj.elementDensityCreatorType = 'ElementalDensityCreatorByLevelSetCreator';
            obj.pdim                      = '2D';                                   
        end
        
        function createDataBase(obj)
            d = obj.createNumericalHomogenizerDataBase();
           % d.levelSetDataBase       = obj.createLevelSetDataBase();
           % d.materialInterpDataBase = obj.createMaterialInterpDataBase();
           % d.materialDataBase       = obj.createMaterialDataBase();
            d.volumeShFuncDataBase   = obj.createShVolumeDataBase(d);
            obj.dataBase = d;
        end
        
        function d = createNumericalHomogenizerDataBase(obj)
            d = obj.dataBase;
            d.elementDensityCreatorType = obj.elementDensityCreatorType;
            d.outFileName  = 'NumericalHomogenizer';
            d.testName     = obj.femFileName;
            d.print = false;
            d.iter  = 0;
            d.pdim = obj.pdim;
        end
        
        function d = createShVolumeDataBase(obj,dI)
            d = SettingsShapeFunctional();
            d.filterParams.filterType = 'P1';
            s = SettingsDesignVariable();
            s.type = 'Density';
            s.levelSetCreatorSettings.type = 'full';
            
            scalarPr.epsilon = 1e-3;
            s.scalarProductSettings = scalarPr;
            
            fileName = s.mesh;
            dF = FemInputReader_GiD().read(fileName);
            cParams.coord  = dF.coord;
            cParams.connec = dF.connec;
            meshT = Mesh_Total(cParams);
            
            s.mesh = meshT;
            
            d.filterParams.designVar = DesignVariable.create(s);% Density(s);
            d.femSettings.fileName = obj.femFileName;
            d.femSettings.scale = 'MICRO';
            mesh = d.filterParams.designVar.mesh;
            
            microSettings = dI.microProblemCreatorSettings.settings; 
            
            sHomog.type                   = 'ByInterpolation';
            sHomog.interpolation          = microSettings.interpolation.materialInterpolation;
            sHomog.dim                    = dI.pdim;
            sHomog.typeOfMaterial         = microSettings.materialInterpolation.materialType;
            sHomog.constitutiveProperties = microSettings.materialInterpolation.matProp;
            sHomog.nelem                  = size(mesh.coord,1);
            sHomog = SettingsHomogenizedVarComputer.create(sHomog);
            d.homogVarComputer = HomogenizedVarComputer.create(sHomog);
        end
        
        function createMicroProblemCreatorSettings(obj)
            s.levelSet              = obj.createLevelSetDataBase();
            s.interpolation         = obj.createMaterialInterpDataBase();
            s.materialInterpolation = obj.createMaterialDataBase();
            s.elementDensityCreator = obj.elementDensityCreatorType;
            microSettings.settings  = s;
            microSettings.pdim      = obj.pdim;
            microSettings.fileName  = obj.femFileName;
            d = obj.dataBase;
            d.microProblemCreatorSettings = microSettings;
            obj.dataBase = d;
        end
        
        function d = createMaterialInterpDataBase(obj)
            d.materialInterpolation = 'SIMPALL';
            d.dim                   = obj.pdim;
        end
        
    end
    
    methods (Access = private, Static)
        
        function d = createLevelSetDataBase()
            d.type = 'horizontalFibers';
            d.levelOfFibers = 3;
            d.volume = 0.5;
        end
        
        
        function d = createMaterialDataBase()
            d.materialType = 'ISOTROPIC';
            d.matProp.rho_plus = 1;
            d.matProp.rho_minus = 0;
            d.matProp.E_plus = 1;
            d.matProp.E_minus = 1e-3;
            d.matProp.nu_plus = 1/3;
            d.matProp.nu_minus = 1/3;
        end
        
    end
    
    
end