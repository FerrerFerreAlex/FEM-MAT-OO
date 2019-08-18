classdef StressNormShapeFuncCreator < handle
    
    properties (Access = private)
        outFile
        stressShape
        stressShapeDB
        phi
    end
    
    methods (Access = public)
        
        function obj = StressNormShapeFuncCreator(d)
            obj.init(d)
            obj.createStressShapeDataBase();
            obj.createStressShape();
        end
        
        function s = getStressNormShape(obj)
            s = obj.stressShape;
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,d)
            obj.outFile       = d.outFile;
            obj.phi = d.phi;
        end
        
        function createStressShape(obj)
            dB = obj.stressShapeDB;
            sF = ShFunc_StressNormInCell(dB);
            sF.filter.preProcess();
            obj.stressShape = sF;
        end
        
        function createStressShapeDataBase(obj)
            
            fullFileName = fullfile(obj.outFile,'SmoothRectangle');
            
            phiV = obj.phi;
            
            s.filename    = fullFileName;
            s.TOL         = obj.createMaterialProperties();
            s.material    = 'ISOTROPIC';
            s.method      = 'SIMPALL';
            s.pdim        = '2D';
            s.stressHomog = [cos(phiV),sin(phiV),0]';
            s.optimizer   = 'SLERP';
            s.pdim        = '2D';
            
            
            
            femReader = FemInputReader_GiD();
            sM = femReader.read(fullFileName);
            
            mesh = Mesh_Total(sM);
            
            sdV = SettingsDesignVariable();
            sdV.scalarProductSettings.femSettings.fileName = fullFileName;
            sdV.scalarProductSettings.scale = 'MICRO';
            sdV.scalarProductSettings.epsilon = 0.1;
            sdV.type = 'Density';
            sdV.mesh = mesh;
            designVariable = DesignVariable.create(sdV);
            s.designVariable = designVariable;            
            s.targetParameters = [];
            
            
                        %s.mesh = mesh;
            shV = SettingsHomogenizedVarComputerFromInterpolation();
            shV.targetSettings = [];
            shV.targetParams = [];
            shV.designVariable = designVariable;
            s.homogVarComputer = HomogenizedVarComputer.create(shV);
            
            
            
            
            
            s.filterParams.filterType = 'P1';
            s.filterParams.designVar.type = 'Density';
            s.filterParams.designVar.mesh = mesh;
            s.filterParams.femSettings.scale = 'MICRO';
            s.filterParams.femSettings.fileName = fullfile(fullFileName);
            
            
            %s.femSettings.mesh = mesh;
            s.femSettings.scale = 'MICRO';
            s.femSettings.fileName = fullfile(fullFileName);
            obj.stressShapeDB = s;
        end
    end
    
    methods (Access = private, Static)
        
        function matProp = createMaterialProperties()
            matProp.rho_plus  =  1;
            matProp.rho_minus =  0;
            matProp.E_plus    =  1;
            matProp.E_minus   =  1.0000e-03;
            matProp.nu_plus   =  0.3333;
            matProp.nu_minus  =  0.3333;
        end
        
    end
    
end