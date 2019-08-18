classdef OptimalSuperEllipseExponentComputer < handle
    
    properties (Access = private)
        maxStress
        volume
        parameters
        lambda
        qMeanOpt
    end
    
    methods (Access = public)
        
        function obj = OptimalSuperEllipseExponentComputer()
            obj.init()
            obj.loadMaxStressAndVolumeData();
            obj.computeMeanOptimalExponent();
            obj.plot();
        end
        
    end
    
    methods (Access = private)
        
        function init(obj)
             obj.loadMaxStressAndVolumeData();
             obj.lambda = 100;
        end
        
        function loadMaxStressAndVolumeData(obj)
            path = 'Topology Optimization/Vademecums';
            file = 'SuperEllipseMaxStressVolume.mat';
            fileFull = fullfile(path,file);
            d = load(fileFull);
            obj.maxStress = d.data.maxStress;
            obj.volume    = d.data.volume;
            obj.parameters = d.data.parameters;
        end
        
        function computeMeanOptimalExponent(obj)
            p = obj.parameters;
            for imx = 1:p.mx.n
                for imy = 1:p.my.n
                    obj.updateLoopIndex(imx,imy);
                    obj.obtainMeanOptimalExponent();
                end
            end
        end
        
        function updateLoopIndex(obj,imx,imy)
            obj.parameters.mx.imx = imx;
            obj.parameters.my.imy = imy;
        end
        
        function obtainMeanOptimalExponent(obj)
            p    = obj.parameters;
            imx  = p.mx.imx;
            imy  = p.my.imy;
            qOpt = obj.obtainOptimalExponentsForAllPhi();
            obj.qMeanOpt(imx,imy) = mean(qOpt);            
        end        
        
        function q = obtainOptimalExponentsForAllPhi(obj)
            p = obj.parameters;
            q = zeros(p.phi.n,1);
            for iphi = 1:p.phi.n
                obj.updateIphi(iphi);
                q = obj.obtainExponentWithMinCostFunction();
            end            
        end
                
        function updateIphi(obj,iphi)
           obj.parameters.phi.iphi = iphi; 
        end
        
        function qOpt = obtainExponentWithMinCostFunction(obj)
            q = obj.parameters.q.values;
            c = obj.obtainCostFunction();
            [~,imin] = min(c);
            qOpt = q(imin); 
        end
        
        function c = obtainCostFunction(obj)
            s = obj.obtainMaxStress();
            v = obj.obtainVolume();
            l = obj.lambda;
            c = s + l*v;            
        end
        
        function s = obtainMaxStress(obj)
            p    = obj.parameters;
            imx  = p.mx.imx;
            imy  = p.my.imy;
            iphi = p.phi.iphi;
            s    = obj.maxStress(imx,imy,:,iphi);
            s    = squeeze(s);
        end
        
        function v = obtainVolume(obj)
            p = obj.parameters;
            imx = p.mx.imx;
            imy = p.my.imy;
            v   = obj.volume(imx,imy,:);
        end
        
        function plot(obj)
            mx = obj.parameters.mx.values;
            my = obj.parameters.my.values;
            q  = obj.qMeanOpt;
            surf(mx,my,q');            
        end
        
    end
    
end
