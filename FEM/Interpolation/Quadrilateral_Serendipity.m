classdef Quadrilateral_Serendipity < Interpolation    
    %% !! SHAPE FUNCTIONS & DERIVATIVES SHOULD BE REVISED !!
    % Source: http://www.ce.memphis.edu/7111/notes/class_notes/chapter_03e_slides.pdf
    
    methods
        function obj = Quadrilateral_Serendipity(mesh,order)
            obj =  obj@Interpolation(mesh,order);
            obj.type = 'QUADRILATERAL';
            obj.ndime = 2;
            obj.nnode = 8;
            obj.ngaus = 9;
            
            % Compute WEIGP and POSGP
            a =  0.77459667;
            obj.posgp(1,:) = [ 0,+a];
            obj.posgp(2,:) = [ 0, 0];
            obj.posgp(3,:) = [+a,+a];
            obj.posgp(4,:) = [-a,-a];
            obj.posgp(5,:) = [-a, 0];
            obj.posgp(6,:) = [+a, 0];
            obj.posgp(7,:) = [+a,-a];
            obj.posgp(8,:) = [-a,+a];
            obj.posgp(9,:) = [ 0,-a];
            obj.posgp = obj.posgp';
            obj.weigp = 1*ones(1,obj.ngaus);
            
            for igaus = 1:obj.ngaus
                s = obj.posgp(1,igaus);
                t = obj.posgp(2,igaus);
                
                % Shape Functions
                obj.shape(1,igaus) = (1-s)*(1-t)*(-1-s-t)*0.25;
                obj.shape(2,igaus) = (1+s)*(1-t)*(-1+s-t)*0.25;
                obj.shape(3,igaus) = (1+s)*(1+t)*(-1+s+t)*0.25;
                obj.shape(4,igaus) = (1-s)*(1+t)*(-1-s+t)*0.25;
                obj.shape(5,igaus) = (1-s^2)*(1-t)*0.5;
                obj.shape(6,igaus) = (1+s)*(1-t^2)*0.5;
                obj.shape(7,igaus) = (1-s^2)*(1+t)*0.5;
                obj.shape(8,igaus) = (1-s)*(1-t^2)*0.5;
                
                % SF Derivatives
                obj.deriv(1,1,igaus) = (1-t)*(2*s+t)*0.25;
                obj.deriv(1,2,igaus) = (1-t)*(2*s-t)*0.25;
                obj.deriv(1,3,igaus) = (1+t)*(2*s+t)*0.25;
                obj.deriv(1,4,igaus) = (1+t)*(2*s-t)*0.25;
                obj.deriv(1,5,igaus) = -s*(1-t);
                obj.deriv(1,6,igaus) = (1-t^2)*0.5;
                obj.deriv(1,7,igaus) = -s*(1+t);
                obj.deriv(1,8,igaus) = -(1-t^2)*0.5;
                
                obj.deriv(2,1,igaus) = (1-s)*(s+2*t)*0.25;
                obj.deriv(2,2,igaus) = (1+s)*(2*t-s)*0.25;
                obj.deriv(2,3,igaus) = (1+s)*(s+2*t)*0.25;
                obj.deriv(2,4,igaus) = (1-s)*(2*t-s)*0.25;
                obj.deriv(2,5,igaus) = -(1-s^2)*0.5;
                obj.deriv(2,6,igaus) = -t*(1+s);
                obj.deriv(2,7,igaus) = (1-s^2)*0.5;
                obj.deriv(2,8,igaus) = -t*(1-s);
            end
        end
    end
    
end