classdef testUnfittedSurfaceIntegration < testUnfittedGeometricalIntegration   
    methods (Access = protected)
        function A = computeGeometricalVariable(obj)
            A = obj.mesh.computeSurface();
        end
    end
end

