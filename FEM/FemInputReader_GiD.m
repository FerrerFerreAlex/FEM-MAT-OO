classdef FemInputReader_GiD < handle
    
    properties (GetAccess = public,SetAccess = public)
        pdim
        dirichlet
        pointload
    end
    
    properties (GetAccess = public,SetAccess = public)
        ptype
        scale
        problemID
    end
    
    properties (Access = public)
        geometryType
        coord
        connec
    end
    
    methods (Access = public)
        
        function s = read(obj,fileName)
            obj.readFile(fileName);
            s = obj.getData();
        end
        
        function s = getData(obj)
            s.mesh = Mesh().create(obj.coord,obj.connec);
            s.pdim = obj.pdim;
            s.geometryType = obj.geometryType;
            s.ptype = obj.ptype;
            s.scale = obj.scale;
            s.problemID = obj.problemID;
            s.dirichlet = obj.dirichlet;
            s.pointload = obj.pointload;
        end
        
    end
    
    methods (Access = private)
        
        function readFile(obj,fileName)
            data = Preprocess.readFromGiD(fileName);
            obj.pdim = data.problem_dim;
            obj.geometryType = data.geometry;
            obj.ptype = data.problem_type;
            obj.scale = data.scale;
            obj.problemID = fileName;
            obj.coord = data.xpoints;
            ndim = obj.getDimension();
            obj.coord  = obj.coord(:,2:ndim+1);
            obj.connec = data.connectivities(:,2:end);
            
            if strcmpi(data.problem_type,'elastic')
                obj.dirichlet = data.dirichlet_data;
                obj.pointload = data.pointload;
            end
        end
        
        function d = getDimension(obj)
            switch obj.pdim
                case '2D'
                    d = 2;
                case '3D'
                    d = 3;
            end
        end
        
    end
    
end