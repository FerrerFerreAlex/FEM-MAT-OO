classdef ComputingCutMeshVectorized < handle
    
    properties (Access = public)

    end
    
    properties (Access = private)
        t2
        t1
        boundaryMesh
        uMesh        
        
        subCellCases  
        cutCoordComputer
        cutEdgesComputer
        coord
    end
    
    properties (Access = private)
        backgroundMesh
        levelSet
        boundaryConnec
        
    end
    
    methods (Access = public)
        
        function obj = ComputingCutMeshVectorized(cParams)
            obj.init(cParams)            
        end
        
        function error = compute(obj)
            obj.createBoundaryMesh();
           tic            
            obj.createUnfittedMesh();
          obj.t1 = toc;
            obj.plotUnfittedMesh();
          tic  
          
%         function init(obj,cParams)
%             obj.levelSet       = cParams.levelSet;
%             obj.backgroundMesh = cParams.backgroundMesh;
%             obj.cutCells       = cParams.cutCells;
%         end          
          
          
          
            error = obj.computeCutPoints();    
          obj.t2 =   toc;
          ratio = obj.t1/obj.t2
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.levelSet = cParams.levelSet;
            obj.backgroundMesh = cParams.backgroundMesh;
            obj.boundaryConnec = cParams.boundaryConnec;
        end
        
         function createBoundaryMesh(obj)
            connec = obj.boundaryConnec;
            for iFace = 1:size(connec,1)
               con = connec(iFace,:);
               s.coord =  obj.backgroundMesh.coord(con,:);
               s.nodesInBoxFaces = con;
               s.connec = [1 2 3];
               s.kFace = 0;
               s.dimension = [];
               s.isRectangularBox = false;
               m{iFace} = BoundaryMesh(s);
            end
            obj.boundaryMesh = m;
        end
        
        function createUnfittedMesh(obj)
            s.boundaryMesh   = obj.boundaryMesh;
            s.backgroundMesh = obj.backgroundMesh;
            obj.uMesh = UnfittedMesh(s);
            obj.uMesh.compute(obj.levelSet)            
        end
        
        function plotUnfittedMesh(obj)
            obj.uMesh.plotBoundary()
            view([1 1 1])
        end
        
        function computeSubCellCases(obj)
            s.connec     = obj.backgroundMesh.connec;
            s.levelSet   = obj.levelSet;
            obj.subCellCases = SubCellsCasesComputer(s);
            obj.subCellCases.compute();
        end
        
        function computeCutEdges(obj)
            obj.backgroundMesh.computeEdges();
            e = obj.backgroundMesh.edges;
            s.nodesInEdges = e.nodesInEdges;
            s.levelSet     = obj.levelSet;       
            c = CutEdgesComputer(s);
            c.compute();
            obj.cutEdgesComputer = c;                           
        end
        
        function computeCutCoordinateComputer(obj)
            e = obj.backgroundMesh.edges;            
            sC.coord            = obj.backgroundMesh.coord;
            sC.nodesInEdges     = e.nodesInEdges;  
            sC.xCutEdgePoint    = obj.cutEdgesComputer.xCutEdgePoint;
            sC.isEdgeCut        = obj.cutEdgesComputer.isEdgeCut;
            cComputer = CutCoordinatesComputer(sC);
            cComputer.compute();        
            obj.cutCoordComputer = cComputer;                      
        end
        
        function plotPoints(obj)
            x = obj.cutCoordComputer.xCutPoints(:,1);
            y = obj.cutCoordComputer.xCutPoints(:,2);
            z = obj.cutCoordComputer.xCutPoints(:,3);
            hold on
            plot3(x,y,z,'k*','LineWidth',10,'MarkerSize',10,'MarkerFaceColor','k','MarkerEdgeColor','k')                
        end
        
        function error = computeCutPoints(obj)
            obj.computeSubCellCases();
            obj.computeCutEdges();
            obj.computeCutCoordinateComputer();  
            obj.coord = obj.cutCoordComputer.coord;
            obj.plotPoints();          
                 
            e = obj.backgroundMesh.edges;
            s.edgesInElem   = e.edgesInElem;
            s.isEdgeCut     = obj.cutEdgesComputer.isEdgeCut;
            isEdgeCut       = EdgeCutInElemComputer(s);
            isEdgeCutInElem = isEdgeCut.compute();                   
            
            
%             e = obj.backgroundMesh.edges;
%             nEdgesCutCase   = [3 4];
%             nSubCellsByElem = [4 6];
%             
%             subCell = cell(length(nEdgesCutCase),1);
%             nCutEdges = sum(isEdgeCutInElem,1);
%             for icases = 1:length(nEdgesCutCase)
%                 t = nCutEdges == nEdgesCutCase(icases);
%                 isEdgeCutInElemCase = isEdgeCutInElem(:,t);
%                 
%                 s.isEdgeCutInElem = isEdgeCutInElemCase;
%                 all2Cut = AllEdges2CutEdgesComputer(s);
%                 
%                 cEp.all2Cut = all2Cut;
%                 cEp.allNodesinElemParams.finalNodeNumber = size(obj.backgroundMesh.coord,1);
%                 cEp.allNodesinElemParams.connec = obj.backgroundMesh.connec(t,:);
%                 cEp.allNodesInElemCoordParams.localNodeByEdgeByElem = e.localNodeByEdgeByElem(t,:,:);
%                 cEp.edgesInElem = e.edgesInElem(t,:);
%                 cEp.nEdgeByElem = e.nEdgeByElem;
%                 cEp.isEdgeCut = obj.cutEdgesComputer.isEdgeCut;
%                 cEp.allNodesInElemCoordParams.xCutEdgePoint = obj.cutEdgesComputer.xCutEdgePoint;
%                 cEp.isEdgeCutInElem = isEdgeCutInElemCase;
%                 cE = CutPointsInElemComputer(cEp);
%                 cE.compute();
%                 
%                 caseInfo = obj.subCellCases.caseInfo{icases};
%                 
%             
%                 nodes = obj.backgroundMesh.connec;
%                 cutCells(:,1) = 1:size(nodes,1);
%                 
%                 
%                 
%                 sS.bestSubCellCaseSelector.coord = obj.backgroundMesh.coord;
%                 sA.subMeshConnecParams           = sS;
%                 sA.xAllNodesInElem               = cE.xAllNodesInElem;
%                 sA.allNodesInElem                = cE.allNodesInElem;
%                 sA.subCellCases                  = caseInfo.subCellCases(t,:);
%                 
%                 sI.allSubCellsConnecParams = sA;
%                 sI.isSubCellInterior = caseInfo.isSubCellsInterior(:,t);
%                 sI.cutElems = cutCells;
%                 
%                 sI.nSubCellsByElem = nSubCellsByElem(icases);
%                 
%                 if ~isempty(sI.isSubCellInterior)
%                 subCell{icases} = InteriorSubCellsConnecComputer(sI);
%                 end
%             
%             end
%             
%             connecT = [];
%             xCoordsIso = [];
%             cellC = [];
%             
% 
%             for icase = 1:2
%                subC = subCell{icase};
%                if ~isempty(subC)                 
%                  connecT = cat(1,connecT,subC.connec);
%                  xCoordsIso = cat(3,xCoordsIso,subC.xCoordsIso);
% 
%                  cellC = cat(1,cellC,subC.cellContainingSubcell);                 
%                end
%             end
%             
%             connec                = connecT;
%             xCoordsIso            = xCoordsIso;
%             cellContainingSubcell = cellC;
            

  e = obj.backgroundMesh.edges;
            nEdgesCutCase   = [2 3 4];
            nSubCellsByElem = [3 4 6];
            
            subCell = cell(length(nEdgesCutCase),1);
            cN = cell(length(nEdgesCutCase),1);
            
            nCutEdges = sum(isEdgeCutInElem,1);
            for icases = 1:length(nEdgesCutCase)
                t = nCutEdges == nEdgesCutCase(icases);
                isEdgeCutInElemCase = isEdgeCutInElem(:,t);
                
                s.isEdgeCutInElem = isEdgeCutInElemCase;
                all2Cut = AllEdges2CutEdgesComputer(s);
                
                cEp.all2Cut = all2Cut;
                cEp.allNodesinElemParams.finalNodeNumber = size(obj.backgroundMesh.coord,1);
                cEp.allNodesinElemParams.connec = obj.backgroundMesh.connec(t,:);
                cEp.allNodesInElemCoordParams.localNodeByEdgeByElem = e.localNodeByEdgeByElem(t,:,:);
                cEp.edgesInElem = e.edgesInElem(t,:);
                cEp.nEdgeByElem = e.nEdgeByElem;
                cEp.isEdgeCut = obj.cutEdgesComputer.isEdgeCut;
                cEp.allNodesInElemCoordParams.xCutEdgePoint = obj.cutEdgesComputer.xCutEdgePoint;
                cEp.isEdgeCutInElem = isEdgeCutInElemCase;
                cE = CutPointsInElemComputer(cEp);
                cE.compute();
                
                
                
                if sum(t) ~= 0
                    
                cN{icases} = cE;
    
                caseInfo = obj.subCellCases.caseInfo{icases};
                
            
                nodes = obj.backgroundMesh.connec;
                cutCells(:,1) = 1:size(nodes,1);
                
                
                
                sS.bestSubCellCaseSelector.coord = obj.coord;
                sA.subMeshConnecParams           = sS;
                sA.xAllNodesInElem               = cE.xAllNodesInElem;
                sA.allNodesInElem                = cE.allNodesInElem;
                sA.subCellCases                  = caseInfo.subCellCases(t,:);
                
                sI.allSubCellsConnecParams = sA;
                sI.isSubCellInterior = caseInfo.isSubCellsInterior(:,t);
                sI.cutElems = cutCells;
                
                sI.nSubCellsByElem = nSubCellsByElem(icases);
                
                
                    subCell{icases} = InteriorSubCellsConnecComputer(sI);
                end
            
            end
            
            connecT = [];
            xCoordsIso = [];
            cellC = [];
            
            xCoordsIsoBoundary = [];
            cellContainingSubCellBoundary = [];

            for icase = 1:3
               subC = subCell{icase};
               scN  = cN{icases};
               if ~isempty(subC)                 
                 connecT = cat(1,connecT,subC.connec);
                 xCoordsIso = cat(3,xCoordsIso,subC.xCoordsIso);
                 cellC = cat(1,cellC,subC.cellContainingSubcell);
               end
               
               if ~isempty(scN)  
                 xCoordsIsoBoundary = cat(3,xCoordsIsoBoundary,scN.xCutInElem); 
                % cellContainingSubCellBoundary = cat(1,cellContainingSubCellBoundary,obj.cutCells);
               end
               
            end
            
            connec                = connecT;
           % xCoordsIso            = xCoordsIso;
            cellContainingSubcell = cellC;   
            xCoordsIsoBoundary = xCoordsIsoBoundary;
 



            error = obj.createInnerCutAndPlot(connec,obj.coord,xCoordsIso,cellContainingSubcell);
            
            
        end
        
        
        
        function error = createInnerCutAndPlot(obj,connec,coord,xCoordsIso,cellContainingSubcell)            
          
            if ~isempty(obj.uMesh.innerCutMesh)
            quad = Quadrature.set(obj.uMesh.innerCutMesh.mesh.type);
            quad.computeQuadrature('CONSTANT');          
            
            vR = obj.uMesh.innerCutMesh.mesh.computeDvolume(quad);

            sM.connec = connec
            sM.coord  = coord
            
            m = Mesh(sM);
            s.mesh                  = m;
            s.xCoordsIso            = xCoordsIso;
            s.cellContainingSubcell = cellContainingSubcell;
            innerCutMesh = InnerCutMesh(s);

            
            connecU = obj.uMesh.innerCutMesh.mesh.connec
            connecI = innerCutMesh.mesh.connec
            
            
            vA = innerCutMesh.mesh.computeDvolume(quad);
            
            vAT = zeros(size(vR));
            vAT(1:length(vA)) = vA;
            volums = [vR; vAT]'
            
            error = abs(sum(vA) - sum(vR))
            else
                error = 0
            end
        end
        
    end
    
end