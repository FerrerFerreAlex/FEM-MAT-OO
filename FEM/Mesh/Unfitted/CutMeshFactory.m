classdef CutMeshFactory < handle
    

    methods (Access = public)
        
        function c = create(obj,cParams)
             bMesh    = cParams.backgroundMesh;
             bCutMesh = obj.computeBackgroundCutMesh(bMesh,cParams.cutCells);

            switch cParams.backgroundMesh.type
                case 'LINE'
                    s.backgroundMesh    = bCutMesh;
                    s.cutCells          = cParams.cutCells;
                    s.levelSet          = cParams.levelSet;
                    c = CutMeshProvisionalLine(s);
                case 'TRIANGLE'
                    s.backgroundMesh = bCutMesh;
                    s.cutCells       = cParams.cutCells;
                    s.levelSet       = cParams.levelSet;
                    c = CutMeshComputerProvisional(s);
                                                           
                case 'QUAD'
                    s.backgroundMesh    = bCutMesh;                    
                    s.cutCells          = cParams.cutCells;
                    s.levelSet          = cParams.levelSet;
                    s.lastNode          = max(cParams.backgroundMesh.connec(:));
                    c = CutMeshProvisionalQuadrilater(s);
                otherwise
                    s.backgroundMesh    = bMesh;                    
                    s.cutCells          = cParams.cutCells;
                    s.levelSet          = cParams.levelSet;
                    s.type              = cParams.type;
                    c = CutMeshProvisionalOthers(s);                
            end

                
        end
        
    end
    
    methods (Access = private, Static)
        
        function m = computeBackgroundCutMesh(bMesh,cutCells)
            s.coord  = bMesh.coord;
            s.connec = bMesh.connec(cutCells,:);
            s.kFace  = bMesh.kFace;
            m = Mesh(s);             
        end
    end
    
end