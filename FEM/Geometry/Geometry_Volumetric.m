classdef Geometry_Volumetric < Geometry
    
    properties (GetAccess = public, SetAccess = private)
        xGauss
        cartd
        dvolu
    end
    
    properties (Access = private)
        matrixInverter
        interpolationGeometry
        interpolationVariable
        quadrature
        nElem
        coordElem
        jacobian
        detJ
    end
    
    methods (Access = public)
        
        function obj = Geometry_Volumetric(cParams)
            obj.init(cParams)
        end
        
        function computeGeometry(obj,quad,interpV)
            obj.initGeometry(interpV,quad);
            obj.computeElementCoordinates();
            obj.computeGaussPointsPosition();
            for igaus = 1:obj.quadrature.ngaus
                obj.computeJacobian(igaus);
                obj.computeJacobianDeterminant(igaus);
                obj.computeDvolu(igaus);
                obj.computeCartesianDerivatives(igaus);
            end
        end
        
    end
    methods (Access = private)
        
        function init(obj,cParams)
            obj.nElem = cParams.mesh.nelem;
            obj.interpolationGeometry = Interpolation.create(cParams.mesh,'LINEAR');
        end
        
        function initGeometry(obj,interpV,quad)
            obj.interpolationVariable = interpV;
            obj.quadrature = quad;
            obj.computeShapeFunctions();
            obj.initDvolu();
            obj.initDetJ();
            obj.initCartD();
            obj.matrixInverter = MatrixVectorizedInverter();
        end
        
        function computeShapeFunctions(obj)
            xpg = obj.quadrature.posgp;
            obj.interpolationVariable.computeShapeDeriv(xpg)
            obj.interpolationGeometry.computeShapeDeriv(xpg);
        end
        
        function initDvolu(obj)
            nGaus     = obj.quadrature.ngaus;
            obj.dvolu = zeros(obj.nElem,nGaus);
        end
        
        function initDetJ(obj)
            nGaus    = obj.quadrature.ngaus;
            obj.detJ = zeros(obj.nElem,nGaus);
        end
        
        function initCartD(obj)
            nDime = obj.interpolationVariable.ndime;
            nNode = obj.interpolationVariable.nnode;
            nGaus = obj.quadrature.ngaus;
            obj.cartd  = zeros(nDime,nNode,obj.nElem,nGaus);
        end
        
        function computeGaussPointsPosition(obj)
            nNode  = obj.interpolationGeometry.nnode;
            nDime  = obj.interpolationGeometry.ndime;
            shapes = obj.interpolationGeometry.shape;
            nGaus  = obj.quadrature.ngaus;
            xGaus = zeros(nGaus,nDime,obj.nElem);
            for kNode = 1:nNode
                shapeKJ(:,1) = shapes(kNode,:)';
                xKJ = obj.coordElem(kNode,:,:);
                xG = bsxfun(@times,shapeKJ,xKJ);
                xGaus = xGaus + xG;
            end
            obj.xGauss = permute(xGaus,[2 1 3]);
        end
        
        function computeElementCoordinates(obj)
            nNode  = obj.interpolationGeometry.nnode;
            nDime  = obj.interpolationGeometry.ndime;
            coord  = obj.interpolationGeometry.xpoints;
            connec = obj.interpolationGeometry.T;
            coordE = zeros(nNode,nDime,obj.nElem);
            coord  = coord';
            for inode = 1:nNode
                nodes = connec(:,inode);
                coordNodes = coord(:,nodes);
                coordE(inode,:,:) = coordNodes;
            end
            obj.coordElem = coordE;
        end
        
        function computeJacobian(obj,igaus)
            nDime   = obj.interpolationGeometry.ndime;
            nNode   = obj.interpolationGeometry.nnode;
            dShapes = obj.interpolationGeometry.deriv(:,:,igaus);
            jac = zeros(nDime,nDime,obj.nElem);
            for kNode = 1:nNode
                dShapeIK = dShapes(:,kNode);
                xKJ      = obj.coordElem(kNode,:,:);
                jacIJ    = bsxfun(@times, dShapeIK, xKJ);
                jac = jac + jacIJ;
            end
            obj.jacobian = jac;
        end
        
        function computeJacobianDeterminant(obj,igaus)
            J = obj.jacobian;
            obj.detJ(:,igaus) = obj.matrixInverter.computeDeterminant(J);
        end
        
        function computeDvolu(obj,igaus)
            w = obj.quadrature.weigp;
            obj.dvolu(:,igaus) = w(igaus)*obj.detJ(:,igaus);
        end
        
        function computeCartesianDerivatives(obj,igaus)
            nNode   = obj.interpolationVariable.nnode;
            nDime   = obj.interpolationVariable.ndime;
            dShapes = obj.interpolationVariable.deriv(:,:,igaus);
            invJ     = obj.computeInvJacobian();
            dShapeDx = zeros(nDime,nNode,obj.nElem);
            for jDime = 1:nDime
                invJ_JI   = invJ(:,jDime,:);
                dShape_KJ = dShapes(jDime,:);
                dSDx_KI   = bsxfun(@times, invJ_JI,dShape_KJ);
                dShapeDx  = dShapeDx + dSDx_KI;
            end
            obj.cartd(:,:,:,igaus) = dShapeDx;
        end
        
        function invJ = computeInvJacobian(obj)
            jac = obj.jacobian;
            invJ = obj.matrixInverter.computeInverse(jac);
        end
        
    end
    
end