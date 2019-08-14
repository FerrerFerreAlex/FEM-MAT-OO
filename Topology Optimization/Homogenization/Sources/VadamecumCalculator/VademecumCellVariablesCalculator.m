classdef VademecumCellVariablesCalculator < handle
    
    properties (Access = public)
       variables 
    end
    
    properties (Access = private)
        fileNames        
        homog
        
        iMxIndex
        iMyIndex
        mxV
        myV
        iter
        freeFemSettings
        print
        superEllipseExponent
    end
    
    methods (Access = public)
        
        function obj = VademecumCellVariablesCalculator(d)
            obj.init(d);
        end
        
        function computeVademecumData(obj)
            nMx = length(obj.mxV);
            nMy = length(obj.myV);
            for imx = 1:nMx
                for imy = 1:nMy
                    obj.storeIndex(imx,imy);
                    obj.iter = (imy + nMx*(imx -1));
                    %disp([num2str(obj.iter/(nMx*nMy)*100),'% done']);                    
                    obj.generateInputFemFile();
                    obj.computeNumericalHomogenizer();
                    obj.obtainHomogenizedData();
                end
            end
        end        
        
        function saveVademecumData(obj)
           d = obj.getData();
           fN = obj.fileNames.fileName;
           pD = obj.fileNames.printingDir;
           file2SaveName = [pD,'/',fN,'.mat'];
           save(file2SaveName,'d');
        end
        
        function d = getData(obj)
            d.variables        = obj.variables;
            d.domVariables.mxV = obj.mxV;
            d.domVariables.myV = obj.myV;
            d.outPutPath       = obj.fileNames.outPutPath;
            d.fileName         = obj.fileNames.fileName;
        end
         
    end    
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.computeFileNames(cParams);
            nMx = cParams.nMx;
            nMy = cParams.nMy;
            obj.mxV = linspace(cParams.mxMin,cParams.mxMax,nMx);
            obj.myV = linspace(cParams.myMin,cParams.myMax,nMy);
            obj.print = cParams.print;
            obj.freeFemSettings = cParams.freeFemSettings;
            obj.createSuperEllipseExponent(cParams);
        end
        
        function computeFileNames(obj,d)
            fN = d.fileName;
            oP = d.outPutPath;
            pD = fullfile(pwd,'Output',fN);
            fNs.fileName    = fN;
            fNs.outPutPath  = oP;
            fNs.printingDir = pD;                        
            fNs.freeFemFileName = d.freeFemFileName;
            obj.fileNames = fNs;
        end        
        
        function createSuperEllipseExponent(obj,cParams)
            s = cParams.superEllipseExponentSettings;
            exponent = SuperEllipseExponent.create(s);
            obj.superEllipseExponent = exponent;            
        end
        
        function storeIndex(obj,imx,imy)
            obj.iMxIndex = imx;
            obj.iMyIndex = imy;
        end        

        function q = computeCornerSmoothingExponent(obj)
            exponent = obj.superEllipseExponent;
            mx = obj.mxV(obj.iMxIndex);
            my = obj.myV(obj.iMyIndex);
            q = exponent.computeValue(mx,my);
        end
    
        function generateInputFemFile(obj)
            s.freeFemSettings  = obj.computeFreeFemSettings();
            s.fileName         = obj.fileNames.fileName;    
            inputFileGenerator = InputFemFileGeneratorFromFreeFem(s); 
            inputFileGenerator.generate();
        end
        
        function s = computeFreeFemSettings(obj)
            s = obj.freeFemSettings;
            s.mxV             = obj.mxV(obj.iMxIndex);
            s.myV             = obj.myV(obj.iMyIndex);
            s.qNorm           = obj.computeCornerSmoothingExponent();           
            s.freeFemFileName = obj.fileNames.freeFemFileName;                                 
        end
             
        function computeNumericalHomogenizer(obj)
            d = obj.createNumericalHomogenizerSettings();
            obj.homog = NumericalHomogenizer(d);
            obj.homog.iter = obj.iter;
            obj.homog.compute();                                
        end
        
        function s = createNumericalHomogenizerSettings(obj)
            outFile = [obj.fileNames.fileName];
            numHomogSett = NumericalHomogenizerDataBase([outFile,'.m']);
            s = numHomogSett.dataBase;
            s.outFileName = outFile;
            s.print       = obj.print;
            s.microProblemCreatorSettings.settings.levelSet.type = 'full';
        end  
        
        function obtainHomogenizedData(obj)
            ix = obj.iMxIndex;
            iy = obj.iMyIndex;            
            s.homogenizer = obj.homog;
            variablesGetter = VademecumVariablesGetter(s);
            obj.variables{ix,iy} = variablesGetter.get();            
        end    
        
    end
    
end