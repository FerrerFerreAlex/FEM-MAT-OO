classdef Postprocess < handle
       
    properties (Access = protected)                  
        outFileName
        
        resultPrinter
        meshPrinter
        
        mshDataBase
        resDataBase        
    end
    
    
     methods (Access = public)
 
        function obj = Postprocess(Postprocess)
            factory  = ResultsPrinterFactory();
            obj.resultPrinter = factory.create(Postprocess);
            obj.meshPrinter = MeshPrinter();
        end
               
        function  print(obj,dataBase)
            obj.init(dataBase);          
            obj.createOutputDirectory();
            obj.printMeshFile();            
            obj.printResFile()
        end
        
        function r = getResFile(obj)
            r = obj.resultPrinter.getResFile();
        end
        
    end
       
    methods (Access = private)
        
        function init(obj,d)
            obj.outFileName = d.outFileName;            
            obj.mshDataBase = obj.computeDataBaseForMeshFile(d);                       
            obj.resDataBase = obj.computeDataBaseForResFile(d); 
        end
                
        function printResFile(obj)
            d = obj.resDataBase;            
            obj.resultPrinter.print(d);            
        end
        
       	function printMeshFile(obj)
            d = obj.mshDataBase;
            obj.meshPrinter.print(d);
        end
        
        function createOutputDirectory(obj)
            path = pwd;
            dir = fullfile(path,'Output',obj.outFileName);
            if ~exist(dir,'dir')
                mkdir(dir)
            end            
        end
    end
    
     methods (Access = private, Static)
        
        function d = computeDataBaseForResFile(dI)
            d.fileID = [];
            d.testName = dI.outFileName;
            d.nsteps = [];
            d.etype = dI.etype;
            d.ptype = dI.ptype;
            d.ngaus = [];
            d.ndim = dI.ndim;
            d.posgp = [];
            d.fields = dI.fields;
            d.istep = dI.iter;              
            d.gaussDescriptor = 'Guass up?';
        end
        
        function d = computeDataBaseForMeshFile(dI)
            d.coordinates = dI.coordinates;
            d.connectivities = dI.connectivities;
            d.testName = dI.outFileName;
            d.npnod = dI.npnod;
            d.pdim = dI.pdim;
            d.nnode = dI.nnode;
            d.nelem = dI.nelem;
            d.ndim = dI.ndim;
            d.etype = dI.etype;
            d.iter = dI.iter;
        end
 
    end

end
