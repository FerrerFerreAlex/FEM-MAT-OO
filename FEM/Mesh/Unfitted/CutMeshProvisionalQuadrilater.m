classdef CutMeshProvisionalQuadrilater < CutMesh
    
    properties (Access = public)
        mesh
        cellContainingSubcell
        xCoordsIso
    end
    
    properties (Access = private)
        connec
        coord
        
       cutMesh 
       subMesh
       subCutSubMesh
       
       subMesher
       
       fullSubCells
       cutSubCells
       levelSetSubMesh
    end
    
    properties (Access = private)
        lastNode
    end
    
    methods (Access = public)
        
        function obj = CutMeshProvisionalQuadrilater(cParams)
            obj.init(cParams);
            obj.lastNode = cParams.lastNode;            
        end
        
        function compute(obj)
            obj.createSubMesher();            
            obj.createSubMesh();
            obj.computeLevelSetInSubMesh();            
            obj.classifyCells();
            obj.computeSubCutSubMesh();
            obj.computeXcoord();            
            obj.computeCoord();
            obj.computeConnec();
            obj.computeCellContainingSubCell(); 
            obj.computeMesh();            
        end
        
    end
    
    methods (Access = protected)
        
        function m = obtainMesh(obj)
            m = obj.mesh;
        end   
        
        function x = obtainXcoordIso(obj)
            x = obj.xCoordsIso;
        end        
        
        function c = obtainCellContainingSubCells(obj)
           c = obj.cellContainingSubcell; 
        end        
        
        function m = obtainBoundaryMesh(obj)
            m = obj.subCutSubMesh.computeBoundaryMesh();
            m = m.mesh;
        end         
        
        function xCutG = obtainBoundaryXcutIso(obj)
            xCutIso = obj.subCutSubMesh.obtainBoundaryXcutIso();
           
            s.fullCells     = obj.fullSubCells;
            s.cutCells      = obj.cutSubCells;
            s.globalToLocal = obj.computeGlobalToLocal();
            s.localMesh     = obj.subMesher.localMesh;
            s.xIsoCutCoord  = xCutIso;
            xC = XcoordIsoComputer(s); 
            xCutG = xC.computeXSubCut();
        
        end
        
        function cellCont = obtainBoundaryCellContainingSubCell(obj)
            cutC = obj.cutSubCells;
            cell = obj.computeSubTriangleOfSubCell();
            cellCont = cell(cutC);
        end        
        
    end   
    
    methods (Access = private)
        
        function createSubMesher(obj)
            s.mesh        = obj.backgroundMesh;
            s.lastNode    = obj.lastNode;
            obj.subMesher = SubMesher(s);            
        end
        
        function createSubMesh(obj)
            obj.subMesh = obj.subMesher.subMesh;
        end
        
        function computeLevelSetInSubMesh(obj)
            ls = obj.levelSet;
            
            s.mesh   = obj.backgroundMesh;
            s.fNodes = ls;
            f = FeFunction(s);
            lsSubMesh = f.computeValueInCenterElement();              
            
            obj.levelSetSubMesh = [ls;lsSubMesh];
        end
        
       function classifyCells(obj)
            lsInElem = obj.computeLevelSetInElem();
            isFull  = all(lsInElem<0,2);
            isEmpty = all(lsInElem>0,2);
            isCut = ~isFull & ~isEmpty;           
            obj.fullSubCells  = find(isFull);
            obj.cutSubCells   = find(isCut);
       end
       
        function lsElem = computeLevelSetInElem(obj)
            ls = obj.levelSetSubMesh;
            nodes = obj.subMesh.connec;
            nnode = size(nodes,2);
            nElem = size(nodes,1);
            lsElem = zeros(nElem,nnode);
            for inode = 1:nnode 
                node = nodes(:,inode);
                lsElem(:,inode) = ls(node);
            end
        end        
        
        function computeSubCutSubMesh(obj)
            s.backgroundMesh = obj.subMesh;
            s.cutCells       = obj.cutSubCells;
            s.levelSet       = obj.levelSetSubMesh();
            cMesh = CutMesh.create(s);
            cMesh.compute();
            obj.subCutSubMesh = cMesh;
        end
               
        function  computeCellContainingSubCell(obj)
            cellSubMesh = obj.subCutSubMesh.cellContainingSubcell;
            fCells      = obj.fullSubCells;           
            cellSubMesh = [fCells;cellSubMesh];
            
            cell = obj.computeSubTriangleOfSubCell();
            obj.cellContainingSubcell = cell(cellSubMesh);            
        end
        
        function cell = computeSubTriangleOfSubCell(obj)
            nnode  = size(obj.backgroundMesh.connec,2);  
            cElems = transpose(obj.cutCells);
            cell = repmat(cElems,nnode,1);
            cell = cell(:);
        end        
        
        function globalToLocal = computeGlobalToLocal(obj)
            bConnec = obj.backgroundMesh.connec;
            nnode   = size(bConnec,2);
            nElem   = size(bConnec,1);
            cell = repmat((1:nnode)',1,nElem);
            globalToLocal = cell(:);               
        end
        
        function computeXcoord(obj)
            s.fullCells     = obj.fullSubCells;
            s.cutCells      = obj.subCutSubMesh.cellContainingSubcell;
            s.globalToLocal = obj.computeGlobalToLocal();
            s.localMesh     = obj.subMesher.localMesh;
            s.xIsoCutCoord  = obj.subCutSubMesh.xCoordsIso;
            xC = XcoordIsoComputer(s);
            obj.xCoordsIso = xC.compute();
        end
     
        function computeConnec(obj)
            connecCutInterior = obj.subCutSubMesh.mesh.connec;
            connecFull        = obj.subMesh.connec(obj.fullSubCells,:);
            obj.connec = [connecFull;connecCutInterior];            
        end
        
        function computeCoord(obj)
            obj.coord  = obj.subCutSubMesh.mesh.coord;            
        end
        
        function computeMesh(obj)
            sM.connec = obj.connec;
            sM.coord  = obj.coord;
            sM.kFace  = obj.backgroundMesh.kFace;
            obj.mesh = Mesh(sM);            
        end        
     
    end
    
end