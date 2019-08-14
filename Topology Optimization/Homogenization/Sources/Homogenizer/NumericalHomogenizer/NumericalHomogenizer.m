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
        hasToCaptureImage
        volDataBase
        
        microProblemCreatorSettings
        microProblemCreator
        
        
        postProcess
        
        resFile
        
        printers
        
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
            obj.volDataBase    = d.volumeShFuncDataBase;
            obj.microProblemCreatorSettings = d.microProblemCreatorSettings;
            obj.hasToCaptureImage = false;
        end
        
        function createMicroProblem(obj)
            s = obj.microProblemCreatorSettings;
            microCreator = MicroProblemCreator(s);
            microCreator.create();
            obj.microProblemCreator = microCreator;
            obj.elemDensCr = microCreator.elemDensCreator;
            obj.matValues  = microCreator.matValues;
        end
   
        function computeCellVariables(obj)
            obj.computeVolumeValue();
            obj.computeElasticVariables();
        end
        
        function computeElasticVariables(obj)
            microProblem = obj.microProblemCreator.microProblem;
            microProblem.computeChomog();
            cV = obj.cellVariables;
            cV.Ch      = microProblem.variables.Chomog;
            cV.tstress = microProblem.variables.tstress;
            cV.tstrain = microProblem.variables.tstrain;
            cV.displ   = microProblem.variables.tdisp; 
            obj.cellVariables = cV;
            microProblem.computeStressBasisCellProblem();
            var = microProblem.variables2printStressBasis();            
        end
        
        function computeVolumeValue(obj)
            microProblem    = obj.microProblemCreator.microProblem;
            density         = obj.microProblemCreator.density;
            elemDensCreator = obj.microProblemCreator.elemDensCreator;
            
            cParams.coord  = microProblem.mesh.coord;
            cParams.connec = microProblem.mesh.connec;
            mesh = Mesh_Total(cParams);                        
            s = SettingsDesignVariable();
            s.type = 'Density';            
            s.mesh = mesh;%obj.microProblem.mesh;

            sl.type  = 'given';
            sl.value = elemDensCreator.getLevelSet();
            sl.ndim  = microProblem.mesh.ndim;
            sl.coord = microProblem.mesh.coord;             
            s.levelSetCreatorSettings = sl;
                       
            scalarPr.epsilon = 1e-3;
            s.scalarProductSettings = scalarPr;            
            designVar = DesignVariable.create(s);
            
            d = obj.volDataBase;            
            d.filterParams.femSettings = d.femSettings;
            d.filterParams.designVar   = designVar;
            d.filterParams = SettingsFilter(d.filterParams);
            
            vComputer = ShFunc_Volume(d);
            vComputer.computeCostFromDensity(density);
            vol = vComputer.value;
            obj.cellVariables.volume = vol;
        end
               
        function obtainIntegrationUsedVariables(obj)  
           microProblem  = obj.microProblemCreator.microProblem;
           intVar.nstre  = microProblem.element.getNstre();
           intVar.geoVol = microProblem.computeGeometricalVolume();
           intVar.ngaus  = microProblem.element.quadrature.ngaus;
           intVar.dV     = microProblem.geometry.dvolu;
           obj.integrationVar = intVar;
        end
        
        function print(obj)
           microProblem  = obj.microProblemCreator.microProblem;     
           density       = obj.microProblemCreator.density;           
            if obj.hasToBePrinted
                obj.createPrintersNames();
                obj.createPostProcess();
                d.var2print = obj.elemDensCr.getFieldsToPrint;
                d.var2print{end+1} = {microProblem,density};
                d.var2print{end+1} = {microProblem,density};
                d.quad = microProblem.element.quadrature;
                obj.postProcess.print(obj.iter,d);
                obj.resFile = obj.postProcess.getResFile();
            end
        end
        
        function createPrintersNames(obj)
            type = obj.microProblemCreatorSettings.eDensCreatType;
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
            dI.mesh            = obj.microProblemCreator.microProblem.mesh;
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

