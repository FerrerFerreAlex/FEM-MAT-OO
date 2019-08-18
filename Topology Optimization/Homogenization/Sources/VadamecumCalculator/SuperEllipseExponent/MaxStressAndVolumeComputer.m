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
    end
    
    
    methods (Access = public)
        
        function obj = MaxStressAndVolumeComputer()
            obj.init();
            obj.computeSuperEllipseMaxStressAndVolume();
        end
        
    end
    
    methods (Access = private)
        
        function init(obj)
            obj.createParameters();
            obj.initMaxStressAndVolume();
            obj.fileName  = 'SmoothRectangle';
            obj.outPutDir = fullfile('Output',obj.fileName);
            obj.hasToPrint = false;
        end
        
        function createParameters(obj)
            s.mx.values = [0.01,0.99,5];
            s.my.values = [0.01,0.99,5];
            s.phi.values = [0,pi/2,7];
            s.q.values = [1,4,10];
            s.q.expo   = 2;
            p = ParametersVademecumCreator(s);
            obj.parameters = p.params;
        end
        
        function initMaxStressAndVolume(obj)
            p = obj.parameters;
            nMx  = p.mx.n;
            nMy  = p.my.n;
            nQ   = p.q.n;
            nPhi = p.phi.n;
            obj.maxStress = zeros(nMx,nMy,nQ,nPhi);
            obj.volume    = zeros(nMx,nMy,nQ);
        end
        
        function computeSuperEllipseMaxStressAndVolume(obj)
            p = obj.parameters;
            nMx  = p.mx.n;
            nMy  = p.my.n;
            nQ   = p.q.n;
            for imx = 1:nMx
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
            path = 'Topology Optimization/Vademecums';
            file = 'SuperEllipseMaxStressVolume.mat';
            fileFull = fullfile(path,file);
            data.maxStress = obj.maxStress;
            data.volume = obj.volume;
            data.parameters = obj.parameters;
            save(fileFull,'data');
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