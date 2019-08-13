classdef VideoMaker < handle
    
    properties (GetAccess = private, SetAccess = public)
        iterations
    end
    
    properties (Access = private)
        gidPath
        tclFileName
        filesFolder
        fileName
        tclFileWriter
        field
        simulationName
    end
    
    methods (Access = public)
        
        function obj = VideoMaker(cParams)
           obj.init(cParams); 
        end
                
        function makeVideo(obj,cParams)
            obj.field = cParams.field;
            obj.makeFieldVideo();
        end
        
    end
      
    methods (Access = protected)
        
        function init(obj,cParams)
            obj.fileName       = cParams.caseFileName;
            obj.simulationName = cParams.simulationName;
            obj.createPaths();
            obj.createFolder();
        end
        
    end
    
    methods (Access = private)
        
        function createFolder(obj)
            if ~exist(obj.filesFolder,'dir')
                mkdir(obj.filesFolder);
            end
        end
        
        function createPaths(obj)
            %obj.gidPath = 'C:\Program Files\GiD\GiD 13.0.4';%
            %obj.gidPath = '/opt/GiDx64/13.0.2/';
            obj.gidPath = '/opt/GiDx64/14.0.1/';            
            obj.filesFolder = fullfile(pwd,'Output',obj.fileName);
        end
        
        function makeFieldVideo(obj)
            obj.createTclFileName();
            obj.createTclFileWriter();
            obj.writeTclFile();
            obj.executeTclFile();
            obj.deleteTclFile();
        end
        
        function createTclFileName(obj)
            fName = 'tcl_gid.tcl';
            obj.tclFileName = fullfile(obj.filesFolder,fName);
        end
        
        function createTclFileWriter(obj)
            s.type           = obj.field.name;
            s.tclFileName    = obj.tclFileName;
            s.filesFolder    = obj.filesFolder;
            s.iterations     = obj.iterations;
            s.fileName       = obj.fileName;
            s.field          = obj.field;
            s.simulationName = obj.simulationName;
            obj.tclFileWriter = TclFileWriter.create(s);
        end
        
        function writeTclFile(obj)
            obj.tclFileWriter.write();
        end
        
        function executeTclFile(obj)
            tFile = replace(obj.tclFileName,'\','\\');
            %gFile = fullfile(obj.gidPath,'gid_offscreen');
            gFile = fullfile(obj.gidPath,'gid');            
            executingLine = ['"',gFile,'"', ' -t ' ,'"source ',tFile,'"'];
            system(executingLine);
        end
        
        function deleteTclFile(obj)
            tFile = obj.tclFileName;
            if ispc
                system(['DEL ',tFile]);
            elseif isunix
                system(['rm ',tFile]);
            elseif ismac
            end
        end
        
    end
    
end
