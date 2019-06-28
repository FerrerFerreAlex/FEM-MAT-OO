classdef AmplificatorTensorFromVademecumInVectorForm < VariableFromVademecum
    
    properties (Access = protected)
        fieldName = 'Ptensor';
    end
    
    properties (Access = private)
        targetParams
        targetSettings
        monomials        
    end
    
    methods (Access = public)
        
        function obj = AmplificatorTensorFromVademecumInVectorForm(cParams)
            obj.init(cParams);
            obj.targetParams = cParams.targetParams;
            obj.targetSettings = cParams.targetSettings;
            obj.obtainValues();
        end
        
        function [P,dP] = compute(obj,x)
            obj.computeParamsInfo(x);
            obj.setValuesToInterpolator(x);
            [P,dP] = obj.computeValues();
        end
        
        function m = getMonomials(obj)
            iPnorm = obj.computePindex();
            m = obj.monomials{iPnorm};
        end
        
    end
    
    methods (Access = protected)
        
        function obtainValues(obj)
            imin = log2(obj.targetSettings.pNormInitial);
            imax = log2(obj.targetSettings.pNormFinal);
            index = imin:imax;
            for iPnorm = 1:length(index)
                monom = obj.vadVariables.monomials{index(iPnorm)};
                obj.monomials{iPnorm} = monom;
                var = obj.vadVariables.variables;
                mxV = obj.vadVariables.domVariables.mxV;
                myV = obj.vadVariables.domVariables.mxV;
                nx = length(mxV);
                ny = length(myV);
                nm = size(monom,1);
                v = zeros(nm,nx,ny);
                for imx = 1:nx
                    for imy = 1:ny
                        Ptensor = var{imx,imy}.(obj.fieldName);
                        v(:,imx,imy) = Ptensor{index(iPnorm)};
                    end
                end
                obj.values{iPnorm} = v;
            end
        end
        
    end
    
    methods (Access = private)
        
        function [P,dP] = computeValues(obj)
            iPnorm = obj.computePindex();
            val = obj.values{iPnorm};            
            ns = size(val,1);
            P  = zeros(ns,obj.nPoints);
            dP = zeros(ns,obj.nPoints,obj.nParams);
            for i = 1:ns
                pv = squeeze(val(i,:,:));
                [p,dp] = obj.interpolator.interpolate(pv);
                P(i,:) = p;
                dP(i,:,1) = dp(:,1);
                dP(i,:,2) = dp(:,2);
            end
        end
        
        function iP = computePindex(obj)
            imin = log2(obj.targetSettings.pNormInitial);
            iPnorm = log2(obj.targetParams.pNorm);
            iP = iPnorm - (imin -1);
        end
        
    end
    
end
