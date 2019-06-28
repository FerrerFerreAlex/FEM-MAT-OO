classdef ShFunc_Volume < ShapeFunctional
    
    properties (Access = private)
        geometricVolume
    end
    
    methods (Access = public)
        
        function obj = ShFunc_Volume(cParams)            
            cParams.filterParams.quadratureOrder = 'CONSTANT';            
            obj.init(cParams);         
            obj.geometricVolume = sum(obj.dvolu(:));
        end
        
        function computeCostAndGradient(obj)
            obj.nVariables = obj.designVariable.nVariables;            
            obj.updateHomogenizedMaterialProperties();            
            obj.computeCost()
            obj.computeGradient()
        end
        
        function computeCost(obj)          
            density = obj.homogenizedVariablesComputer.rho;
            obj.computeCostFromDensity(density);  
            %%% ???
            obj.designVariable.rho = density;
        end        
        
        function computeCostFromDensity(obj,dens)
            densV(:,1) = dens;
            volume = sum(sum(obj.dvolu,2)'*densV);
            volume = volume/(obj.geometricVolume);
            obj.value = volume;            
        end
        
        function d = getDataToPrint(obj)
           x = obj.obtainDesignVariableInMatrix();          
           rho = obj.homogenizedVariablesComputer.calculateDensity(x);            
           d.density = rho;
           d.regDensity = obj.homogenizedVariablesComputer.rho;
        end        
        
        function quad = getQuadrature(obj)
           quad  = obj.filter.quadrature;        
        end        
        
    end
    
    methods (Access = private)

        function computeGradient(obj)
            drho = obj.homogenizedVariablesComputer.drho;
            g = drho/(obj.geometricVolume);
            gf = zeros(size(obj.Msmooth,1),obj.nVariables);
            for ivar = 1:obj.nVariables
                gs = squeeze(g(:,ivar));
                gf(:,ivar) = obj.filter.getP1fromP0(gs);
            end
            g = obj.Msmooth*gf;
            obj.gradient = g(:);            
        end
        
        function updateHomogenizedMaterialProperties(obj)
            xs = obj.obtainDesignVariableInMatrix();
            for ivar = 1:obj.nVariables
               xf(:,ivar) = obj.filter.getP0fromP1(xs(:,ivar));
            end
            obj.homogenizedVariablesComputer.computeDensity(xf);
        end        
        
        function xs = obtainDesignVariableInMatrix(obj)
            nx = length(obj.designVariable.value)/obj.designVariable.nVariables;
            x  = obj.designVariable.value;
            for ivar = 1:obj.nVariables
                i0 = nx*(ivar-1) + 1;
                iF = nx*ivar;
                xs(:,ivar) = x(i0:iF);
            end             
        end
        
    end
end

