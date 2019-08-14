classdef OptimalSuperEllipseExponentComputer < handle
    
    properties (Access = private)
        mxV
        myV
        qV
        fileName
        outPutDir
    end
    
    
    methods (Access = public)
        
        function obj = OptimalSuperEllipseExponentComputer()
            obj.init();
            obj.generateMesh();
            obj.createSwanInputData();
            obj.createMicroProblem();
        end
        
    end
    
    
    methods (Access = private)
        
        function init(obj)
            obj.mxV = 0.5;
            obj.myV = 0.5;
            obj.qV  = 4;
            obj.fileName  = 'SmoothRectangle';
            obj.outPutDir = fullfile('Output',obj.fileName);            
        end
        
        function generateMesh(obj)
            s = SettingsFreeFemMeshGenerator();
            s.mxV             = obj.mxV;
            s.myV             = obj.myV;
            s.fileName        = obj.fileName;
            s.freeFemFileName = obj.fileName;
            s.printingDir     = obj.outPutDir;
            s.qNorm           = obj.qV;
            fG = FreeFemMeshGenerator(s);
            fG.generate();
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
            defaultDB = NumericalHomogenizerDataBase([obj.fileName,'.m']);
            dB = defaultDB.dataBase;
            dB.outFileName = obj.fileName;
            dB.microProblemCreatorSettings.settings.levelSet.type = 'full';           
            s = dB.microProblemCreatorSettings;
            microCreator = MicroProblemCreator(s);
            microCreator.create();
            
            
        end
               
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
end