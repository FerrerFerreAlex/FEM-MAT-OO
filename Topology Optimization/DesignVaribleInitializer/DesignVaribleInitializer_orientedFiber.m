classdef DesignVaribleInitializer_orientedFiber < LevelSetCreator
        
        properties (Access = private)
            dir
            RotMatrix
            alpha

            width
            v
            levelOfFibers
            fiberPosition
        end
        
        methods
        
        function obj = DesignVaribleInitializer_orientedFiber(input)
            obj.compute(input);
            obj.fiberPosition = input.yn;
            obj.levelOfFibers = input.levFib;
            obj.computeInitialLevelSet()
        end
        end
        
        methods (Access = protected)
        
        function computeInitialLevelSet(obj)   
            phi = obj.computeHorizontalFibersLevelSet();
            obj.x = phi;           
        end                
        
        end
    
        
        methods (Access = private)
            function UB = computeLaminateUpperBound(obj,xc,yc)
                UB = obj.RotMatrix(2,1)*(obj.mesh.coord(:,1)-xc) + obj.RotMatrix(2,2)*(obj.mesh.coord(:,2)-yc) - (obj.width/2 -1e-6);                
            end

            function LB = computeLaminateLowerBound(obj,xc,yc)
                LB = obj.RotMatrix(2,1)*(obj.mesh.coord(:,1)-xc) + obj.RotMatrix(2,2)*(obj.mesh.coord(:,2)-yc) + (obj.width/2 -1e-6);                
            end
            
            function isVoid = isVoid(obj,s)
            
            vect = obj.v(s);
            xc = vect(1);
            yc = vect(2);

            UB = obj.computeLaminateUpperBound(xc,yc);
            LB = obj.computeLaminateLowerBound(xc,yc);
            isVoid = UB < 0 & LB > 0;                 
                
            end
           
                    
            function phi = computeHorizontalFibersLevelSet(obj)
                m = obj.levelOfFibers;
                y = obj.fiberPosition;
                period = 1/(2^m);
                phase = period/4 - mod(period/4,0.00625);
                phi = -sin(2*pi/period*(y-phase));
            end
            
        end
end

