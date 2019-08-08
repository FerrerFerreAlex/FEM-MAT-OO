classdef GiDImageCapturer
    
    properties (Access = private)
        gidPath = '/opt/GiDx64/13.0.2/'
        pathTcl = '/home/alex/git-repos/SwanLab/Swan/PostProcess/ImageCapturer/';
        outPutFolderPath = '/home/alex/Dropbox/Amplificators/Images/'
        resultsFile
        outputImageName
    end
    
    methods (Access = public)
        
        function obj = GiDImageCapturer(fileName,outPutImageName,inputFileName)
            obj.init(fileName,outPutImageName,inputFileName)
        end
    end
    
    methods (Access = private)
        
        function init(obj,fileName,outPutImageName,inputFileName)
            obj.resultsFile = fileName;
            obj.outputImageName = [obj.outPutFolderPath,outPutImageName];
            obj.createOutPutImageFolder()
            obj.writeCallGiDTclFile(obj.pathTcl,inputFileName,obj.outputImageName);
            command = [obj.gidPath,'gid_offscreen -offscreen -t "source ',obj.pathTcl,'callGiDCapturer.tcl"'];
            system(command);
            obj.cropImage();
        end
        
        function cropImage(obj)
            s.width = 500;
            s.height = 500;
            s.right = 0;
            s.up    = 0;
            s.inputImage  = obj.outputImageName;
            s.outputImage = obj.outputImageName;
            cropper = Cropper(s);
            cropper.crop();
        end
        
        function createOutPutImageFolder(obj)
            dir = obj.outputImageName;
            if ~exist(dir,'dir')
                mkdir(dir)
                addpath(dir)
            end
        end
        
    end
    
    methods (Access = private, Static)
        
        function writeCallGiDTclFile(pathTcl,inputFile,outputImageName)
            tclFile = 'callGiDCapturer.tcl';
            inputFile = char(inputFile);
            stlFileTocall = 'CaptureImage.tcl';
            fid = fopen([pathTcl,tclFile],'w+');
            fprintf(fid,['set path "',pathTcl,'"\n']);
            fprintf(fid,['set tclFile "',stlFileTocall,'"\n']);
            fprintf(fid,['source $path$tclFile \n']);
            fprintf(fid,['set output ',outputImageName,' \n']);
            fprintf(fid,['set inputFile ',inputFile,'\n']);
            fprintf(fid,['CaptureImage $inputFile $output \n']);
            fclose(fid);
        end
        
    end
    
end


