classdef Mesh_Unfitted_2D_Boundary < Mesh_Unfitted_2D & Mesh_Unfitted_Boundary
    methods
        function obj = Mesh_Unfitted_2D_Boundary(fitted_mesh,fitted_geom_interpolation)
            obj.storeFittedMesh(fitted_mesh,fitted_geom_interpolation);
            obj.geometryType = 'LINE';
            obj.max_subcells = 2;
            obj.nnodes_subcell = 2;
        end
        
        %         function [facets_coord_iso,facets_coord_global,facets_x_value,facets_connec] = computeSubcells(obj,~,subcell_cutPoints_iso,subcell_cutPoints_global)
        %             % !! MOVE THIS TO THE BOUNDARY SUPERCLASS !!
        %             facets_coord_iso = subcell_cutPoints_iso;
        %             facets_coord_global = subcell_cutPoints_global;
        %             facets_x_value = zeros(1,size(subcell_cutPoints_iso,1));
        %
        %             facets_connec = obj.computeFacetsConnectivities(facets_coord_iso);
        %         end
        
        function plot(obj)
            figure, hold on
            for icell = 1:size(obj.unfitted_connec_global,1)
                plot(obj.unfitted_coord_global(obj.unfitted_connec_global(icell,:),1),obj.unfitted_coord_global(obj.unfitted_connec_global(icell,:),2),'k-');
            end
            axis equal off
            hold off
        end
    end
    
    methods (Static, Access = ?Mesh_Unfitted_Boundary)
        function facets_connec = computeFacetsConnectivities(facets_coord_iso,~,~)
            if size(facets_coord_iso,1) == 2
                facets_connec = [1 2];
            elseif size(facets_coord_iso,1) == 4
                DT = delaunayTriangulation(facets_coord_iso);
                delaunay_connec = DT.ConnectivityList;
                
                node_positive_iso = find(obj.x_fitted(inode_global)>0);
                % !! CHECK IF NEXT LINE WORKS !!
                % facets_connec = zeros(length(node_positive_iso),size(delaunay_connec,2));
                for idel = 1:length(node_positive_iso)
                    [connec_positive_nodes, ~] = find(delaunay_connec==node_positive_iso(idel));
                    facets_connec(idel,:) = delaunay_connec(connec_positive_nodes(end),delaunay_connec(connec_positive_nodes(end),:)~=node_positive_iso(idel))-interpolation.nnode;
                end
            else
                error('Case not considered.')
            end
        end
    end
end