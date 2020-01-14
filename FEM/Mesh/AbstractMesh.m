classdef AbstractMesh < handle
    
    properties (Access = public)
        unfittedType        
    end
    
    
    properties (GetAccess = public, SetAccess = public)
        coord
        connec
        
        nelem
        geometryType
    end
    
end