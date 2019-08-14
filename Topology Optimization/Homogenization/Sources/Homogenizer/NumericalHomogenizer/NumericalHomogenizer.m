classdef NumericalHomogenizer < handle
    
    properties (Access = public)
       iter 
    end
        
    properties (SetAccess = private, GetAccess = public)
        matValues
        elemDensCr
        cellVariables
        integrationVar        
    end
    
    properties (Access = private)
        fileName
        outputName
        hasToBePrinted
        pdim
        eDensCreatType
        hasToCaptureImage = false
        
        lsDataBase
        matDataBase
        interDataBase
        volDataBase
        
        matProp
        
        postProcess
        
        microProblem
        density
        levelSet
        resFile
        
        printers
        interpolation
        
    end
    
    methods (Access = public)
        
        function obj = NumericalHomogenizer(d)
            obj.init(d);
        end
        
        function compute(obj)
            obj.createMicroProblem();
            obj.computeCellVariables();
            obj.obtainIntegrationUsedVariables();
            obj.print();
            obj.captureImage();            
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,d)
            obj.fileName       = d.testName;
            obj.outputName     = d.outFileName;
            obj.hasToBePrinted = d.print;
            obj.iter           = d.iter;
            obj.pdim           = d.pdim;
            obj.eDensCreatType = d.elementDensityCreatorType;
            obj.lsDataBase     = d.levelSetDataBase;
            obj.matDataBase    = d.materialDataBase;
            obj.interDataBase  = d.materialInterpDataBase;
            obj.volDataBase    = d.volumeShFuncDataBase;
        end
        
        function createMicroProblem(obj)
            s.fileName       = obj.fileName;
            s.pdim           = obj.pdim;
            s.settings.materialInterpolation = obj.matDataBase;
            s.settings.levelSet              = obj.lsDataBase;
            s.settings.interpolation         = obj.interDataBase;
            s.settings.elementDensityCreator = obj.eDensCreatType;
            microCreator = MicroProblemCreator(s);
            microCreator.create();
            obj.microProblem = microCreator.microProblem;
            obj.density      = microCreator.density;
            obj.elemDensCr   = microCreator.elemDensCr;
            obj.eDensCreatType = microCreator.eDensCreatType;
            obj.matValues = microCreator.matValues;
        end
   
        function computeCellVariables(obj)
            obj.computeVolumeValue();
            obj.computeElasticVariables();
        end
        
        function computeElasticVariables(obj)
            obj.microProblem.computeChomog();
            cV = obj.cellVariables;
            cV.Ch      = obj.microProblem.variables.Chomog;
            cV.tstress = obj.microProblem.variables.tstress;
            cV.tstrain = obj.microProblem.variables.tstrain;
            cV.displ   = obj.microProblem.variables.tdisp; 
            obj.cellVariables = cV;
            
            
            obj.microProblem.computeStressBasisCellProblem();
            var = obj.microProblem.variables2printStressBasis();            
        end
        
        function computeVolumeValue(obj)
            cParams.coord  = obj.microProblem.mesh.coord;
            cParams.connec = obj.microProblem.mesh.connec;
            mesh = Mesh_Total(cParams);                        
            d = obj.volDataBase;
            s = SettingsDesignVariable();
            s.type = 'Density';            
            s.mesh = mesh;%obj.microProblem.mesh;
            s.levelSetCreatorSettings.type  = 'given';
            s.levelSetCreatorSettings.value = obj.elemDensCr.getLevelSet();
            s.levelSetCreatorSettings.ndim  = obj.microProblem.mesh.ndim;
            s.levelSetCreatorSettings.coord = obj.microProblem.mesh.coord; 
            scalarPr.epsilon = 1e-3;
            s.scalarProductSettings = scalarPr;
            d.filterParams.femSettings = d.femSettings;
            d.filterParams.designVar = DesignVariable.create(s);
            d.filterParams = SettingsFilter(d.filterParams);
            vComputer = ShFunc_Volume(d);
            vComputer.computeCostFromDensity(obj.density);
            vol = vComputer.value;
            obj.cellVariables.volume = vol;
        end
               
        function obtainIntegrationUsedVariables(obj)        
           intVar.nstre  = obj.microProblem.element.getNstre();
           intVar.geoVol = obj.microProblem.computeGeometricalVolume();
           intVar.ngaus  = obj.microProblem.element.quadrature.ngaus;
           intVar.dV     = obj.microProblem.geometry.dvolu;
           obj.integrationVar = intVar;
        end
        
        function print(obj)
            if obj.hasToBePrinted
                obj.createPrintersNames();
                obj.createPostProcess();
                d.var2print = obj.elemDensCr.getFieldsToPrint;
                d.var2print{end+1} = {obj.microProblem,obj.density};
                d.var2print{end+1} = {obj.microProblem,obj.density};
                d.quad = obj.microProblem.element.quadrature;
                obj.postProcess.print(obj.iter,d);
                obj.resFile = obj.postProcess.getResFile();
            end
        end
        
        function createPrintersNames(obj)
            type = obj.eDensCreatType;
            f = ElementalDensityCreatorFactory();
            obj.printers = f.createPrinters(type);
            obj.printers{end+1} = 'HomogenizedTensor';
            obj.printers{end+1} = 'HomogenizedTensorStressBasis';
        end
        
        function createPostProcess(obj)
            dB = obj.createPostProcessDataBase();
            dB.printers = obj.printers;
            postCase = 'NumericalHomogenizer';
            obj.postProcess = Postprocess(postCase,dB);
        end
        
        function dB = createPostProcessDataBase(obj)
            dI.mesh            = obj.microProblem.mesh;
            dI.outName         = obj.outputName;
            dI.pdim            = obj.pdim;
            dI.ptype           = 'MICRO';
            ps = PostProcessDataBaseCreator(dI);
            dB = ps.getValue();
        end
        
        function captureImage(obj)
            if obj.hasToCaptureImage
                i = obj.iter;
                f = obj.resFile;
                outPutNameWithIter = [obj.outputName,num2str(i)];
                inputFileName = fullfile('Output',f,[f,num2str(i),'.flavia.res']);
                GiDImageCapturer(f,outPutNameWithIter,inputFileName);
            end
        end
        
    end
    
end

