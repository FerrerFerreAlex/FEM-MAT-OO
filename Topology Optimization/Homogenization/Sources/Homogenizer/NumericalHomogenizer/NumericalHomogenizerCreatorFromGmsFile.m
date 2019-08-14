classdef NumericalHomogenizerCreatorFromGmsFile < handle
    
    properties (Access = private)
        gmsFile        
        outFile
        homog 
        homogDataBase     
        print
        iter
    end
   
    methods (Access = public)
        
        function obj = NumericalHomogenizerCreatorFromGmsFile(d)
            obj.init(d)
            obj.createSwanInputData();
            obj.createNumericalHomogenizerDataBase();
            obj.createNumericalHomogenizer();
        end
        
        function h = getHomogenizer(obj)
            h = obj.homog;
        end
        
        function h = getHomogenizerDataBase(obj)
            h = obj.homogDataBase;
        end        
        
    end
    
    methods (Access = private)
        
        function init(obj,d)
            obj.gmsFile = d.gmsFile;
            obj.outFile = d.outFile;
            obj.print   = d.print;
            obj.iter    = d.iter;
        end
                 
        function createSwanInputData(obj)
            outPutFileName   = fullfile('Output',obj.outFile);
            s.gmsFile        = obj.gmsFile;
            s.outPutDir      = outPutFileName;
            s.outPutFileName = fullfile(outPutFileName,[obj.outFile,'.m']);                    
            c = GmsFile2SwanFileConverter(s);
            c.convert();
        end        
        
        function createNumericalHomogenizerDataBase(obj)
            defaultDB = NumericalHomogenizerDataBase([obj.outFile,'.m']);
            dB = defaultDB.dataBase;
            dB.outFileName = obj.outFile;
            dB.print       = obj.print;
            dB.microProblemCreatorSettings.settings.levelSet.type = 'full';
            obj.homogDataBase = dB;
        end  
        
        function createNumericalHomogenizer(obj)
            d = obj.homogDataBase;
            obj.homog = NumericalHomogenizer(d);
            obj.homog.iter = obj.iter;
            obj.homog.compute();                                
        end
        
    end
    
    
end