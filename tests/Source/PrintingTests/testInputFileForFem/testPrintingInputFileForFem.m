classdef testPrintingInputFileForFem < testNotShowingError
    
    properties (Access = private)
        fileName 
        gmsFile 
        resultsDir
        fullFileName
    end
    
    methods (Access = public)
        
        function obj = testPrintingInputFileForFem()
            obj.init();
            s.gmsFile        = obj.gmsFile;
            s.outPutDir      = obj.resultsDir;
            s.outPutFileName = obj.fullFileName;
            c = GmsFile2SwanFileConverter(s);
            c.convert();
        end
        
    end
    
    methods (Access = protected)
        
        function hasPassed = hasPassed(obj)
            sF = fullfile('tests','PrintingTests',['test',obj.fileName],['test',obj.fileName,'.m']);
            oF = obj.fullFileName;
            hasChanged = FileComparator().areFilesDifferent(sF,oF);
            hasPassed = ~hasChanged;
        end        
        
    end
        
    methods (Access = private)
        
        function init(obj)
            obj.fileName = 'InputFileForFem';
            obj.gmsFile  = 'testReadingGmsh.msh';            
            obj.resultsDir   = fullfile('Output',obj.fileName);
            obj.fullFileName = fullfile(obj.resultsDir,[obj.fileName,'.m']);
        end

    end
    
    
end
