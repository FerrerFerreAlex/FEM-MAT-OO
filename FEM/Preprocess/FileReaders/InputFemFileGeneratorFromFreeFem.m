classdef InputFemFileGeneratorFromFreeFem < handle
    
    properties (Access = private)
        outFile
        freeFemSettings
        fileName
        printingDir
        outPutFileName
    end
        
    
    methods (Access = public)
        
        function obj = InputFemFileGeneratorFromFreeFem(cParams)
            obj.init(cParams)
        end
        
        function generate(obj)
            obj.generateMeshFile();
            obj.createSwanInputData();            
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.fileName        = cParams.fileName;
            obj.freeFemSettings = cParams.freeFemSettings;
            obj.outPutFileName  = fullfile('Output',obj.fileName);
            obj.printingDir     = fullfile(pwd,obj.outPutFileName); 
        end
        
        function generateMeshFile(obj)
            s = obj.freeFemSettings;
            s.fileName        = obj.fileName;            
            s.printingDir     = obj.printingDir;
            fG = FreeFemMeshGenerator(s);
            fG.generate();
        end        
        
        function createSwanInputData(obj)
            gmsFile = [fullfile(obj.printingDir,obj.fileName),'.msh'];
            outName = [fullfile(obj.outPutFileName,obj.fileName),'.m'];
            s.gmsFile        = gmsFile;
            s.outPutDir      = obj.outPutFileName;
            s.outPutFileName = outName;
            c = GmsFile2SwanFileConverter(s);
            c.convert();
        end
        
    end
    
    
    
    
    
end