classdef Cropper < handle
    
    properties (Access = private)
       outputImage 
       inputImage
       inPutFileName
       outPutFileName
       commandToExecute
       position
       positionString
    end
    
    methods (Access = public)
        
        function obj = Cropper(cParams)
            obj.inputImage  = cParams.inputImage;
            obj.outputImage = cParams.outputImage;
            obj.position.width  = cParams.width;
            obj.position.height = cParams.height;
            obj.position.right  = cParams.right;
            obj.position.up   = cParams.up;            
        end
        
        function crop(obj)
           obj.createInPutFileName();            
           obj.createOutPutFileName();
           obj.createPositionString();
           obj.createCommandString();
           obj.executeCommand();
        end
        
    end
    
    methods (Access = private)
        
        function createInPutFileName(obj)
            fName = obj.inputImage;
            obj.inPutFileName = [' ',fName,'.png'];            
        end
        
        function createOutPutFileName(obj)
            fName = obj.outputImage;
            obj.outPutFileName = [' ',fName,'.png'];
        end
        
        function createCommandString(obj)
          inFile  = obj.inPutFileName;
          outFile = obj.outPutFileName;
          pStr    = obj.positionString;
          str1    = 'convert ';
          str2    = [' -crop',' ',pStr];
          str3    = ' -gravity Center ';
          command = strcat(str1,inFile,str2,str3,outFile);
          obj.commandToExecute = command;
        end
        
        function executeCommand(obj)
            command = obj.commandToExecute;
            system(command);
        end
        
        function createPositionString(obj)
            w = num2str(obj.position.width);
            h = num2str(obj.position.height);
            r = num2str(obj.position.right);
            u = num2str(obj.position.up);
            obj.positionString = strcat(w,'x',h,'+',r,'+',u);
        end
    end
    
    
end