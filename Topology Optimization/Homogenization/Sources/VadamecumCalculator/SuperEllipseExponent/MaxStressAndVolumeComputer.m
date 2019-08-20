classdef MaxStressAndVolumeComputer < handle
    
    properties (Access = private)
        index
        parameters
        
        volume
        maxStress
        
        shapeStressNorm
        
        fileName
        outPutDir
        microProblem
        
        hasToPrint
        printers
        postProcess
        
        savedFileName
        
        firstImx
        hasComputationStarted
    end
    
    
    methods (Access = public)
        
        function obj = MaxStressAndVolumeComputer()
            obj.init();
            obj.computeSuperEllipseMaxStressAndVolume();
        end
        
    end
    
    methods (Access = private)
        
        function init(obj)
            obj.fileName  = 'SmoothRectangle';
            obj.outPutDir = fullfile('Output',obj.fileName); 
            obj.hasComputationStarted = true;            
            obj.createSavedFileName();
            obj.initMaxStressAndVolume();
            obj.hasToPrint = false;
        end
        
        function createSavedFileName(obj)
            path = 'Topology Optimization/Vademecums';
            file = 'SuperEllipseMaxStressVolumeMesh2.mat';
            fileFull = fullfile(path,file);            
            obj.savedFileName = fileFull;
        end        
        
        function createParameters(obj)
            s.mx.values = [0.01,0.99,10];
            s.my.values = [0.01,0.99,10];
            s.phi.values = [0,pi/2,7];
            s.q.values = [1,4,20];
            s.q.expo   = 2;
            p = ParametersVademecumCreator(s);
            obj.parameters = p.params;
        end
        
        function initMaxStressAndVolume(obj)
            if obj.hasComputationStarted
                s =  load(obj.savedFileName);
                obj.maxStress = s.data.maxStress;
                obj.volume   = s.data.volume;
                obj.parameters = s.data.parameters;
                obj.firstImx = obj.computeFirstImxWhenSomeComputationDone();
            else
                obj.createParameters();                
                p = obj.parameters;
                nMx  = p.mx.n;
                nMy  = p.my.n;
                nQ   = p.q.n;
                nPhi = p.phi.n;
                obj.maxStress = zeros(nMx,nMy,nQ,nPhi);
                obj.volume    = zeros(nMx,nMy,nQ);                
                obj.firstImx = 1;
            end
        end
        
        function imx0 = computeFirstImxWhenSomeComputationDone(obj)
            stresses = obj.maxStress(:,end,end,end);
            lastComputedStress = find(stresses ~= 0,1,'last');
            imx0 = lastComputedStress + 1;
        end
        
        function computeSuperEllipseMaxStressAndVolume(obj)
            p = obj.parameters;
            nMx  = p.mx.n;
            nMy  = p.my.n;
            nQ   = p.q.n;
            for imx = obj.firstImx:nMx
                for imy = 1:nMy
                    for iq = 1:nQ
                        obj.updateLoopIndex(imx,imy,iq);
                        obj.updateParameters();
                        obj.generateMesh();
                        obj.createSwanInputData();
                        obj.createMicroProblem();
                        obj.computeMaxStresses()
                        obj.print();
                        obj.computeVolume();
                        obj.saveData();
                    end
                    obj.displayIteration();
                end
            end
        end
        
        function displayIteration(obj)
            imx = obj.index.imx;
            imy = obj.index.imy;
            nMx = obj.parameters.mx.n;
            nMy = obj.parameters.my.n;
            iter = (imy + nMx*(imx -1));
            iterPer = iter/(nMx*nMy)*100;
            disp([num2str(iterPer),'% done']);
        end
        
        function saveData(obj)
            data.maxStress = obj.maxStress;
            data.volume = obj.volume;
            data.parameters = obj.parameters;
            save(obj.savedFileName,'data');
        end
                
        function updateLoopIndex(obj,imx,imy,iq)
            obj.index.imx = imx;
            obj.index.imy = imy;
            obj.index.iq  = iq;
        end
        
        function updateParameters(obj)
            p  = obj.parameters;
            in = obj.index;
            p.mx.value = p.mx.values(in.imx);
            p.my.value = p.my.values(in.imy);
            p.q.value  = p.q.values(in.iq);
            obj.parameters = p;
        end
        
        function computeMaxStresses(obj)
            p = obj.parameters;
            nPhi = p.phi.n;
            for iphi = 1:nPhi
                obj.updatePhi(iphi);
                obj.createShapeStressNorm();
                obj.computeMaxStress();
            end
        end
        
        function updatePhi(obj,iphi)
            obj.index.iPhi = iphi;
            p = obj.parameters;
            p.phi.value = p.phi.values(iphi);
            obj.parameters = p;
        end
        
        function generateMesh(obj)
            s.freeFemSettings  = obj.computeFreeFemSettings();
            s.fileName         = obj.fileName;
            inputFileGenerator = InputFemFileGeneratorFromFreeFem(s);
            inputFileGenerator.generate();
        end
        
        function s = computeFreeFemSettings(obj)
            s = SettingsFreeFemMeshGenerator();
            s.mxV             = obj.parameters.mx.value;
            s.myV             = obj.parameters.my.value;
            s.qNorm           = obj.parameters.q.value;
            s.freeFemFileName = obj.fileName;
        end
        
        function createSwanInputData(obj)
            outPutFileName   = obj.outPutDir;
            s.gmsFile        = obj.createGmsFile();
            s.outPutDir      = outPutFileName;
            s.outPutFileName = fullfile(outPutFileName,[obj.fileName,'.m']);
            c = GmsFile2SwanFileConverter(s);
            c.convert();
        end
        
        function n = createGmsFile(obj)
            fN  = obj.fileName;
            dir = fullfile(pwd,obj.outPutDir);
            n = [fullfile(dir,fN),'.msh'];
        end
        
        function createMicroProblem(obj)
            numHomogSettings = NumericalHomogenizerDataBase([obj.fileName,'.m']);
            s = numHomogSettings.dataBase;
            s.outFileName = obj.fileName;
            mS = s.microProblemCreatorSettings;
            mS.settings.levelSet.type = 'full';
            s = s.microProblemCreatorSettings;
            microCreator = MicroProblemCreator(s);
            microCreator.create();
            obj.microProblem = microCreator.microProblem;
        end
        
        function createShapeStressNorm(obj)
            d.outFile = obj.outPutDir;
            d.phi     = obj.parameters.phi.value;
            sNormCreator = StressNormShapeFuncCreator(d);
            sNorm = sNormCreator.getStressNormShape();
            obj.shapeStressNorm = sNorm;
        end
        
        function computeVolume(obj)
            dvolu = sum(obj.microProblem.geometry.dvolu);
            imx = obj.index.imx;
            imy = obj.index.imy;
            iq  = obj.index.iq;
            obj.volume(imx,imy,iq) = sum(dvolu);
        end
        
        function s = computeMaxStress(obj)
            sNorm = obj.shapeStressNorm;
            imx  = obj.index.imx;
            imy  = obj.index.imy;
            iq   = obj.index.iq;
            iPhi = obj.index.iPhi;
            s = sNorm.computeMaxStressWithFullDomain();
            obj.maxStress(imx,imy,iq,iPhi) = s;
        end
        
        function print(obj)
            if obj.hasToPrint
                mProblems  = obj.shapeStressNorm.getPhysicalProblems;
                mProblem = mProblems{1};
                mProblem.computeStressBasisCellProblem();
                nnodes = size(mProblem.mesh.coord,1);
                density = ones(nnodes,1);
                obj.createPrintersNames();
                obj.createPostProcess();
                d.var2print{1} = {mProblem,density};
                d.var2print{2} = {mProblem,density};
                d.quad = mProblem.element.quadrature;
                iter = 1;
                obj.postProcess.print(iter,d);
            end
        end
        
        function createPrintersNames(obj)
            obj.printers{1} = 'HomogenizedTensor';
            obj.printers{2} = 'HomogenizedTensorStressBasis';
        end
        
        function createPostProcess(obj)
            s = obj.createPostProcessDataBase();
            s.printers = obj.printers;
            postCase = 'NumericalHomogenizer';
            obj.postProcess = Postprocess(postCase,s);
        end
        
        
        function cParams = createPostProcessDataBase(obj)
            mProblems  = obj.shapeStressNorm.getPhysicalProblems;
            mProblem = mProblems{1};
            s.mesh            = mProblem.mesh;
            s.outName         = obj.fileName;
            s.pdim            = '2D';
            s.ptype           = 'MICRO';
            ps = PostProcessDataBaseCreator(s);
            cParams = ps.getValue();
        end
        
    end
    
end