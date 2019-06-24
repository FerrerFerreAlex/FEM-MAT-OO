classdef AmplificatorTensorFromVademecumInVectorForm < VariableFromVademecum
    
    
    properties (Access = protected)
        fieldName = 'Ptensor';
    end
    
    properties (Access = private)
        monomials
        pNorm
    end
    
    methods (Access = public)
        
        function obj = AmplificatorTensorFromVademecumInVectorForm(cParams)
            obj.init(cParams);
            obj.pNorm = cParams.pNorm;            
            obj.obtainValues();            
        end
        
        function [P,dP] = compute(obj,x)
            obj.computeParamsInfo(x);
            obj.setValuesToInterpolator(x);
            [P,dP] = obj.computeValues();
        end
        
    end
    
    methods (Access = protected)
        
        function obtainValues(obj)
            iPnorm = log2(obj.pNorm);
            obj.monomials = obj.vadVariables.monomials{iPnorm};
            var = obj.vadVariables.variables;
            mxV = obj.vadVariables.domVariables.mxV;
            myV = obj.vadVariables.domVariables.mxV;
            for imx = 1:length(mxV)
                for imy = 1:length(myV)
                    Ptensor = var{imx,imy}.(obj.fieldName);
                    v(:,imx,imy) = Ptensor{iPnorm};
                end
            end
            obj.values = v;
        end
        
    end
    
    methods (Access = private)
        
        function [P,dP] = computeValues(obj)
            ns = size(obj.values,1);
            P  = zeros(ns,obj.nPoints);
            dP = zeros(ns,obj.nPoints,obj.nParams);
            for i = 1:ns
                    pv = squeeze(obj.values(i,:,:));
                    [p,dp] = obj.interpolator.interpolate(pv);
                    P(i,:) = p;
                    dP(i,:,1) = dp(:,1);
                    dP(i,:,2) = dp(:,2);
            end
        end

    end
    
 end
