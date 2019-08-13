classdef MakingImagesForMicroStress < handle
    
    properties (Access = private)
        microCases
        stressCases
        cropperSettings
        videoMakerSettings
        videoMaker
        index
        caseStr
        imageName
    end    
    
    methods (Access = public)
                
        function obj = MakingImagesForMicroStress()
            obj.init();
            for itxi = 1:length(obj.microCases.txi)
                for irho = 1:length(obj.microCases.rho)
                    for iq = 1:length(obj.microCases.q)
                        for icase = 1:length(obj.stressCases.pullStress)
                            obj.updateIndeces(itxi,irho,iq,icase);
                            obj.createCaseStr();
                            obj.createVideoMaker();
                            obj.makeVideo();
                            obj.createImageName();
                            obj.cropImage();
                        end
                    end
                end
            end
        end
        
    end
    
    
    methods (Access = private)
        
        function init(obj)
            obj.addPath();
            obj.createMicroCases();
            obj.createVideoMakerSettings();
            obj.createStressCases();
            obj.createCropperSettings();
        end
        
        function addPath(obj)
            pathToAdd = '/home/alex/git-repos/SwanLab/Swan/';
            addpath(genpath(pathToAdd));
        end
        
        function createMicroCases(obj)
            s.rho = {'07','095','099'};
            %s.rho = {'03','07','095','099'};
            s.q   = {'2','4','8','16','32'};
            %s.q   = {'4','8','16','32'};            
            s.txi = {'05'};
            %s.txi = {'1'};            
            obj.microCases = s;
        end
        
        function createStressCases(obj)
            s.pullStress = {'1','2','3','1'};
            s.generatedStress = {'x','y','z','y'};
            obj.stressCases = s;
        end
        
        function createVideoMakerSettings(obj)
            s.shallPrint =  true;
            s.pdim =  '2D';
            s.simulationName = 'NumericalHomogenizer';
            obj.videoMakerSettings = s;
        end
        
        
        function createCropperSettings(obj)
            s.width = 500;
            s.height = 400;
            s.right = 250;
            s.up    = 50;
            obj.cropperSettings = s;
        end
        
        function updateIndeces(obj,itxi,irho,iq,icase)
            obj.index.itxi  = itxi;
            obj.index.irho  = irho;
            obj.index.iq    = iq;
            obj.index.icase = icase;
        end
        
        function createCaseStr(obj)
            ind = obj.index;
            rhoS = strcat(['Rho',obj.microCases.rho{ind.irho}]);
            txiS = strcat(['Txi',obj.microCases.txi{ind.itxi}]);
            qS   = strcat(['Q',obj.microCases.q{ind.iq}]);
            allStr = strcat('CaseOfStudy',rhoS,txiS,qS,'SmoothRectangle');
            obj.caseStr = allStr;
        end
        
        function createVideoMaker(obj)
            s = obj.videoMakerSettings();
            s.caseFileName = obj.caseStr;
            vm = VideoMaker(s);
            vm.iterations = 1;
            obj.videoMaker = vm;
        end
        
        function makeVideo(obj)
            s = obj.createVideoMakerParams();
            obj.videoMaker.makeVideo(s);
        end
        
        function s = createVideoMakerParams(obj)
            s.field.name      = obj.createPullStressString();
            s.field.component = obj.createGeneretedStressString();
        end
        
        function n = createPullStressString(obj)
            icase = obj.index.icase;
            pCase = obj.stressCases.pullStress{icase};
            n = strcat('StressStressBasis',pCase);
        end
        
        function c = createGeneretedStressString(obj)
            icase = obj.index.icase;
            gCase = obj.stressCases.generatedStress{icase};
            c = strcat('S',gCase);
        end
        
        function createImageName(obj)
            s = obj.createVideoMakerParams();
            fileName = [s.field.name,s.field.component,obj.caseStr];
            folderName = obj.caseStr;
            obj.imageName = fullfile('Output/',folderName,fileName);
        end
        
        function cropImage(obj)
            s = obj.cropperSettings;
            s.inputImage  = obj.imageName;
            s.outputImage = obj.imageName;
            cropper = Cropper(s);
            cropper.crop();
        end
        
    end
end