classdef Filter_LevelSet < handle
    properties
        geometry
        quadrature_fitted
        quadrature_unfitted
        interpolation_unfitted
        unfitted_mesh
    end
    
    properties (Access = protected)
        max_subcells
        nnodes_subelem
        ndim
    end
    
    properties (Access = private)
        shapeValues_FullCells % !! ONLY USED WHEN INTEGRATING INTERIOR CELLS !!
    end
    
    methods
        function preProcess(obj)
            obj.quadrature_fitted = Quadrature.set(obj.diffReacProb.geometry.type);
            obj.quadrature_fitted.computeQuadrature('LINEAR');
            
            obj.getQuadrature_Unfitted;
            obj.quadrature_unfitted.computeQuadrature('LINEAR');
            
            obj.createUnfittedMesh_Interior;
            
            obj.getInterpolation_Unfitted;
            
            obj.computeGeometry;
            
            obj.shapeValues_FullCells = obj.integrateFullCells;
            
            MSGID = 'MATLAB:delaunayTriangulation:DupPtsWarnId';
            warning('off', MSGID)
        end
        
        function computeGeometry(obj)
            obj.geometry = Geometry(obj.mesh,'LINEAR');
            obj.geometry.interpolation.computeShapeDeriv(obj.quadrature_fitted.posgp);
            obj.geometry.computeGeometry(obj.quadrature_fitted,obj.geometry.interpolation);
        end
        
        function M2 = computeRHS(obj,x)
            obj.createUnfittedMesh_Interior; % !! DUPLICATED, BUT FOR NOW THIS IS OVERWRITTEN WHEN INTEGRATING FACETS !!
            obj.unfitted_mesh.computeMesh(x);
            obj.unfitted_mesh.computeDvoluCut;
            
            posgp_iso = obj.computePosGP(obj.unfitted_mesh.coord_iso_per_cell,obj.interpolation_unfitted,obj.quadrature_unfitted);
            obj.geometry.interpolation.computeShapeDeriv(squeeze(posgp_iso));
            
            shapeValues_CutCells = obj.integrateCutCells(obj.unfitted_mesh.cell_containing_subcell,obj.unfitted_mesh.dvolu_cut);
            shapeValues_All = obj.assembleShapeValues(obj.shapeValues_FullCells,shapeValues_CutCells);
            
            M2 = obj.rearrangeOutputRHS(shapeValues_All);
        end
        
        function M2=computeRHS_facet(obj,x,F)
            obj.createUnfittedMesh_Boundary; % !! DUPLICATED, BUT FOR NOW THIS IS OVERWRITTEN WHEN INTEGRATING FACETS !!
            obj.unfitted_mesh.computeMesh(x);
            obj.unfitted_mesh.computeGlobalConnectivities;
%                         obj.unfitted_mesh.plot;
            %             obj.unfitted_mesh.computeDvoluCut;
            
            [interpolation_facet,quadrature_facet] = obj.createFacet;
            interp_element = Interpolation.create(obj.mesh,obj.quadrature_fitted.order);
            
            facet_posgp_iso = obj.computePosGP(obj.unfitted_mesh.coord_iso_per_cell,interpolation_facet,quadrature_facet);
            
            shape_all = zeros(obj.nelem,obj.nnode);
            
            for ifacet = 1:size(obj.unfitted_mesh.connec,1)
                icell = obj.unfitted_mesh.cell_containing_subcell(ifacet);
                inode = obj.mesh.connec(icell,:);
                facet_posgp = facet_posgp_iso(:,:,ifacet);
                interp_element.computeShapeDeriv(facet_posgp');
                               
                djacob = obj.mapping(obj.unfitted_mesh.coord(obj.unfitted_mesh.connec(ifacet,:),:),interpolation_facet.dvolu);
                
                f = (interp_element.shape*quadrature_facet.weigp')'*F(inode)/interpolation_facet.dvolu;
                shape_all(icell,:) = shape_all(icell,:) + (interp_element.shape*(djacob.*quadrature_facet.weigp')*f)';
            end
            M2 = obj.rearrangeOutputRHS(shape_all);
        end
        
        function shapeValues_FullCells = integrateFullCells(obj)
            shapeValues_FullCells = zeros(size(obj.mesh.connec,1),size(obj.mesh.connec,2));
            for igauss = 1:size(obj.geometry.interpolation.shape,2)
                shapeValues_FullCells = shapeValues_FullCells + obj.geometry.interpolation.shape(:,igauss)'.*obj.geometry.dvolu(:,igauss);
            end
        end
        
        function shapeValued_CutCells = integrateCutCells(obj,containing_cell,dvolu_cut)
            dvolu_frac = sum(obj.geometry.dvolu,2)/obj.geometry.interpolation.dvolu;
            shapeValued_CutCells = obj.geometry.interpolation.shape'.*dvolu_cut.*dvolu_frac(containing_cell);
        end
        
        function shapeValues_AllCells = assembleShapeValues(obj,shapeValues_FullCells,shapeValues_CutCells)
            shapeValues_AllCells = zeros(size(obj.mesh.connec,1),size(obj.mesh.connec,2));
            shapeValues_AllCells(obj.unfitted_mesh.full_cells,:) = shapeValues_FullCells(obj.unfitted_mesh.full_cells,:);
            
            for i_subcell=1:size(shapeValues_CutCells,2)
                shapeValues_AllCells(:,i_subcell) = shapeValues_AllCells(:,i_subcell)+accumarray(obj.unfitted_mesh.cell_containing_subcell,shapeValues_CutCells(:,i_subcell),[obj.nelem,1],@sum,0);
            end
        end
        
        function M2 = rearrangeOutputRHS(obj,shape_all)
            M2 = zeros(obj.npnod,1);
            for inode = 1:obj.nnode
                M2 = M2 + accumarray(obj.mesh.connec(:,inode),shape_all(:,inode),[obj.npnod,1],@sum,0);
            end
        end
        
        function S = IntegrateFacets(obj,x)
            M2 = obj.computeRHS_facet(x,ones(size(x)));
            S = sum(M2);
        end
        
        function S = IntegrateInteriorCells(obj,x)
            M2 = obj.computeRHS(x);
            S = sum(M2);
        end
    end
    
    methods (Static)
        function [full_elem,cut_elem] = findCutElements(x,connectivities)
            phi_nodes = x(connectivities);
            phi_case = sum((sign(phi_nodes)<0),2);
            
            full_elem = phi_case==size(connectivities,2);
            null_elem = phi_case==0;
            indexes = (1:size(connectivities,1))';
            cut_elem = indexes(~(full_elem+null_elem));
        end
        
        function posgp = computePosGP(subcell_coord,interpolation,quadrature)
            interpolation.computeShapeDeriv(quadrature.posgp);
            posgp = zeros(quadrature.ngaus,size(subcell_coord,3),size(subcell_coord,1));
            for igaus = 1:quadrature.ngaus
                for idime = 1:size(subcell_coord,3)
                    posgp(igaus,idime,:) = subcell_coord(:,:,idime)*interpolation.shape(:,igaus);
                end
            end
        end
    end
    
    %     methods (Abstract)
    %         getQuadratureDel(obj)
    %         getMeshDel(obj)
    %         getInterpolationDel(obj,mesh_del)
    %         computeRHS_facet(obj,x,F)
    %         findCutPoints_Iso(obj,x,cut_elem,interpolation)
    %         %         findCutPoints_Global(obj,x,cut_elem)
    %         %         createFacet(obj)
    %         computeDvoluCut(elcrd)
    %         %         mapping(elem_cutPoints_global,facets_connectivities,facet_deriv,dvolu)
    %     end
end