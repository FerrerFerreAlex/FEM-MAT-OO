classdef OptimalSuperEllipseExponentComputer < handle
    
    properties (Access = private)
        maxStress
        interpMaxStress
        volume
        parameters
        qMeanOpt
        qOpt
        nRho
        nTxi
        mxOptimValues
        myOptimValues
    end
    
    methods (Access = public)
        
        function obj = OptimalSuperEllipseExponentComputer()
            obj.init()
            obj.computeMeanOptimalExponent();
            obj.plotSurface();
        end
        
    end
    
    methods (Access = private)
        
        function init(obj)
            %obj.nRho   = 100;
            %obj.nTxi   = 1;            
            obj.nRho   = 50;
            %obj.nTxi   = 20;
            obj.loadMaxStressAndVolumeData();
            obj.computeRhoDiscretization();
            obj.computeTxiExtremeValues()
        end
        
        function loadMaxStressAndVolumeData(obj)
            path = 'Topology Optimization/Vademecums';
            file = 'SuperEllipseMaxStressVolumeMesh1.mat';
            fileFull = fullfile(path,file);
            d = load(fileFull);
            obj.maxStress = d.data.maxStress;
            obj.volume    = d.data.volume;
            obj.parameters = d.data.parameters;
        end
        
        function computeRhoDiscretization(obj)
            obj.parameters.rho.n = obj.nRho;
            obj.computeRhoExtremeValues();
            obj.createRhoDiscretization();
        end
        
        function computeRhoExtremeValues(obj)
            obj.computeRhoMinValue();
            obj.computeRhoMaxValue();
        end
        
        function computeRhoMinValue(obj)
            p = obj.parameters;
            qMax = max(p.q.values);
            cMax = obj.volumeFractionConstant(qMax);
            mxMax = p.mx.max;
            myMax = p.my.max;
            rhoMin = 1 - cMax*mxMax*myMax;
            obj.parameters.rho.min = rhoMin;
        end
        
        function computeRhoMaxValue(obj)
            p = obj.parameters;
            qMin = min(p.q.values);
            cMin = obj.volumeFractionConstant(qMin);
            mxMin = p.mx.min;
            myMin = p.my.min;
            rhoMax = 1 - cMin*mxMin*myMin;
            obj.parameters.rho.max = rhoMax;
        end
        
        function computeTxiExtremeValues(obj)
            obj.computeTxiMinValue();
            obj.computeTxiMaxValue();
        end
        
        function computeTxiMinValue(obj)
            p = obj.parameters;
            mxMin = p.mx.min;
            myMax = p.my.max;
            txiMin = mxMin/myMax;
            obj.parameters.txi.min = txiMin;
        end
        
        function computeTxiMaxValue(obj)
            p = obj.parameters;
            mxMax = p.mx.max;
            myMin = p.my.min;
            txiMax = mxMax/myMin;
            obj.parameters.txi.max = txiMax;
        end
        
        function createRhoDiscretization(obj)

          %  obj.parameters.rho.min = 0.7;
          %  obj.parameters.rho.max = 0.99;
%            obj.parameters.rho.n   = 10;

            p = obj.parameters;

            rhoMin = p.rho.min;
            rhoMax = p.rho.max;
            n      = p.rho.n;
            
            xMax = max(p.mx.max,p.my.max);
            xMin = min(p.mx.min,p.my.min);
            x = linspace(xMin,xMax,n);

            frac = rhoMin/rhoMax;
            n = 0.3;
            a = -(rhoMin - rhoMax)/(xMax^n - xMin^n);
            b = (rhoMin*xMax^n - rhoMax*xMin^n)/(xMax^n - xMin^n);            
            v = a*x.^n+b;

            obj.parameters.rho.values = v;
            
            
        end
        
        function computeMeanOptimalExponent(obj)
            p = obj.parameters;
            for irho = 1:obj.nRho
                obj.updateRhoAndIndex(irho);
                obj.discretizeTxi();
                for itxi = 1:obj.nTxi
                    obj.updateTxiAndIndex(itxi);
                    nphi = p.phi.n;
                    obj.qOpt = zeros(nphi,1);
                    for iphi = 1:nphi
                        obj.updatePhiAndIndex(iphi);
                        obj.discretizeQ();
                        nq = obj.parameters.q.nFeasible;
                        obj.interpMaxStress = zeros(nq,1);
                        for iq = 1:nq
                            obj.updateQAndIndex(iq);
                            obj.computeMxMyValues();
                            obj.interpolateMaxStressForMxMyValues();
                        end
                        obj.obtainOptimalExponent();
                    end
                    obj.obtainMeanOptimalExponent();
                    obj.obtainMxWithMeanOptimalExponent();
                    obj.obtainMyWithMeanOptimalExponent();
                    obj.plot();
                end
            end
        end
        
        function obtainOptimalExponent(obj)
            p    = obj.parameters;
            if p.q.nFeasible > 0
            q    = p.q.feasibleValues;
            iphi = p.phi.iphi;
            s    = obj.interpMaxStress;
            [~,imin] = min(s);
            obj.qOpt(iphi,1) = q(imin);
            end
        end
        
        function obtainMeanOptimalExponent(obj)
            p    = obj.parameters;
            irho = p.rho.irho;
            itxi = p.txi.itxi;
            q    = mean(obj.qOpt);
            obj.qMeanOpt(end+1) = q;
        end
        
        function obtainMxWithMeanOptimalExponent(obj)
            p = obj.parameters;
            irho = p.rho.irho;
            rho = obj.parameters.rho.value;
            itxi = p.txi.itxi;
            txi  = p.txi.value;
            q   = p.q.value;
            c   = obj.volumeFractionConstant(q);            
            mx = obj.mxFunction(rho,txi,c);
            obj.mxOptimValues(end+1) = mx;
        end
        
        function obtainMyWithMeanOptimalExponent(obj)
            p = obj.parameters;
            irho = p.rho.irho;
            rho = obj.parameters.rho.value;            
            itxi = p.txi.itxi;
            txi  = p.txi.value;
            q   = p.q.value;
            c   = obj.volumeFractionConstant(q);
            my = obj.myFunction(rho,txi,c);
            obj.myOptimValues(end+1) = my;
        end
                
        function interpolateMaxStressForMxMyValues(obj)
            p = obj.parameters;
            feasibleQ = find(p.q.feasibleIndex);
            iq   = p.q.iq;
            iphi = p.phi.iphi;
            X = p.mx.values;
            Y = p.my.values;
            V = obj.maxStress(:,:,feasibleQ(iq),iphi);
            x = p.mx.mxV;
            y = p.my.myV;
            v = interp2(X,Y,V,x,y);
            obj.interpMaxStress(iq,1) = v;
        end
        
        function computeMxMyValues(obj)
            obj.computeMx();
            obj.computeMy();
        end
        
        function computeMx(obj)
            p = obj.parameters;
            rho = p.rho.value;
            txi = p.txi.value;
            q   = p.q.value;
            c   = obj.volumeFractionConstant(q);
            mxV = obj.mxFunction(rho,txi,c);
            obj.parameters.mx.mxV = mxV;
        end
        
        function computeMy(obj)
            p = obj.parameters;
            rho = p.rho.value;
            txi = p.txi.value;
            q   = p.q.value;
            c   = obj.volumeFractionConstant(q);
            myV = obj.myFunction(rho,txi,c);
            obj.parameters.my.myV = myV;
        end
        
        function updateRhoAndIndex(obj,irho)
            rho = obj.parameters.rho.values;
            obj.parameters.rho.value = rho(irho);
            obj.parameters.rho.irho = irho;
        end
        
        function updateTxiAndIndex(obj,itxi)
            txi = obj.parameters.txi.values;
            obj.parameters.txi.value = txi(itxi);
            obj.parameters.txi.itxi = itxi;
        end
        
        function updateQAndIndex(obj,iq)
            q = obj.parameters.q.feasibleValues;
            obj.parameters.q.value = q(iq);
            obj.parameters.q.iq = iq;
        end
        
        function updatePhiAndIndex(obj,iphi)
            phi = obj.parameters.phi.values;
            obj.parameters.phi.value = phi(iphi);
            obj.parameters.phi.iphi = iphi;
        end
        
        function discretizeTxi(obj)
           %obj.parameters.txi.n = obj.nTxi;
           % txiMax = obj.computeTxiMax();
           % txiMin = obj.computeTxiMin();
           % txiMin = 0.5;
           % txiMax = 0.5;
           % txi = linspace(txiMin,txiMax,obj.nTxi);
           % obj.parameters.txi.values = txi;
            

           
            p = obj.parameters;
            txiMax = obj.computeTxiMax();
            txiMin = obj.computeTxiMin();
            %n      = p.txi.n;
            obj.nTxi = floor(5^(2*p.rho.value+1));  
            obj.parameters.txi.n = obj.nTxi;
            
            
            xMax = max(p.mx.max,p.my.max);
            xMin = min(p.mx.min,p.my.min);
            x = linspace(xMin,xMax,obj.nTxi);

            frac = txiMin/txiMax;
            n = 1/(1-0.75*p.rho.value);
            a = -(txiMin - txiMax)/(xMax^n - xMin^n);
            b = (txiMin*xMax^n - txiMax*xMin^n)/(xMax^n - xMin^n);            
            v = a*x.^n+b;
            obj.parameters.txi.values = v;

            
        end
        
        function discretizeQ(obj)
            p = obj.parameters;
            feasibleQ = obj.computeFeasibleQ();
            qF = p.q.values(feasibleQ);
            obj.parameters.q.feasibleIndex  = feasibleQ;
            obj.parameters.q.feasibleValues = qF;
            obj.parameters.q.nFeasible      = length(qF);
        end
        
        function feasibleQ = computeFeasibleQ(obj)
           p = obj.parameters;
           feasibleQ = false(p.q.n,1);
           for iq = 1:p.q.n
                q = p.q.values(iq);
                feasibleQ(iq,1) = obj.isQFeasible(q);
           end
        end
        
        function itIs = isQFeasible(obj,q)
           p = obj.parameters;
           rho = p.rho.value;
           txi = p.txi.value;            
           c   = obj.volumeFractionConstant(q);
           mx = obj.mxFunction(rho,txi,c);
           my = obj.myFunction(rho,txi,c);
           isMxFeasible = obj.isMxFeasible(mx);
           isMyFeasible = obj.isMyFeasible(my);
           itIs2 = isMxFeasible && isMyFeasible;
           
           cMin = obj.computeCmin();
           cMax = obj.computeCmax();
           itIs = cMin <= c + 10e-14 && c - 10e-14 <= cMax;
           assert(itIs2 == itIs)
        end
        
        function cMin = computeCmin(obj)
            p = obj.parameters;            
            rho  = obj.parameters.rho.value;
            txi  = obj.parameters.txi.value;            
            mxMax = p.mx.max;
            myMax = p.my.max;            
            cMinForMxMin  = (1-rho)*txi/(mxMax^2);            
            cMinForMyMax  = (1-rho)/(txi*myMax^2);
            cMin = max(cMinForMxMin,cMinForMyMax);            
        end
        
        function cMax = computeCmax(obj)
            p = obj.parameters;
            rho  = obj.parameters.rho.value;
            txi  = obj.parameters.txi.value;            
            mxMin = p.mx.min;
            myMin = p.my.min;            
            cMaxForMxMin  = (1-rho)*txi/(mxMin^2);            
            cMaxForMyMax  = (1-rho)/(txi*myMin^2);
            cMax = min(cMaxForMxMin,cMaxForMyMax);            
        end
        
        function itIs = isMxFeasible(obj,mx)
            mxMax = obj.parameters.mx.max;
            mxMin = obj.parameters.mx.min;
            itIs = mxMin <= mx + 1e-14 && mx - 1e-14 <= mxMax; 
        end
        
        function itIs = isMyFeasible(obj,my)
            myMax = obj.parameters.my.max;
            myMin = obj.parameters.my.min;
            itIs = myMin <= my + 1e-14 && my - 1e-14 <= myMax;
        end            
           
        function txiMin = computeTxiMin(obj)
%             p = obj.parameters;            
%             txiMxMyMin = obj.parameters.txi.min;
%             irho       = obj.parameters.rho.irho;
%             rho = obj.parameters.rho.values(irho);
%             qMax = max(p.q.values);
%             cMax = obj.volumeFractionConstant(qMax);                        
%             mxmyMax = min(p.mx.max,p.my.max);
%             txiRhoMin  = (1-rho)/(cMax*mxmyMax^2);
%             txiMin = max(txiMxMyMin,txiRhoMin);
            p = obj.parameters;            
            irho       = obj.parameters.rho.irho;
            rho = obj.parameters.rho.values(irho);
            qMax = max(p.q.values);
            cMax = obj.volumeFractionConstant(qMax); 
            qMin = max(p.q.values);
            cMin = obj.volumeFractionConstant(qMin);  
            
            mxMin = p.mx.min;
            myMax = p.my.max;
            
            txiMaxForMxMin  = (cMin*mxMin^2)/(1-rho);
            txiMaxForMyMax  = (1-rho)/(cMax*myMax^2);
            txiMin = max(txiMaxForMxMin,txiMaxForMyMax);
        end
        
        function txiMax = computeTxiMax(obj)
%             p = obj.parameters;            
%             txiMxMyMax = obj.parameters.txi.max;
%             irho       = obj.parameters.rho.irho;
%             rho = obj.parameters.rho.values(irho);
%             qMax = max(p.q.values);
%             cMax = obj.volumeFractionConstant(qMax); 
%             mxmyMax = min(p.mx.max,p.my.max);            
%             txiRhoMax  = (cMax*mxmyMax^2)/(1-rho);
%             txiMax = min(txiMxMyMax,txiRhoMax);            


            p = obj.parameters;            
            irho       = obj.parameters.rho.irho;
            rho = obj.parameters.rho.values(irho);
            qMax = max(p.q.values);
            cMax = obj.volumeFractionConstant(qMax); 
            qMin = max(p.q.values);
            cMin = obj.volumeFractionConstant(qMin);  
            
            mxMax = p.mx.max;
            myMin = p.my.min;
            
            txiMaxForMxMax  = (cMax*mxMax^2)/(1-rho);
            txiMaxForMyMin  = (1-rho)/(cMin*myMin^2);
            txiMax = min(txiMaxForMxMax,txiMaxForMyMin);       
        
            
        end
        
        function plot(obj)
            x = obj.mxOptimValues;
            y = obj.myOptimValues;
            z  = obj.qMeanOpt;
            plot3(x,y,z,'+');
            xlabel('mx');
            ylabel('my');
            axis([0 1 0 1 2 16])            
            drawnow();      
            
            
        end
        
        function plotSurface(obj)
            x = obj.mxOptimValues(:);
            y = obj.myOptimValues(:);
            z  = obj.qMeanOpt(:);            
            xlin = linspace(min(x),max(x),50); 
            ylin = linspace(min(y),max(y),50); 
            [X,Y] = meshgrid(xlin,ylin); 
            f = scatteredInterpolant(x,y,z); Z = f(X,Y);           
            figure
            mesh(X,Y,Z)
        end
        
    end
    
    methods (Access = private, Static)
        
        function c = volumeFractionConstant(q)
            c1 = gamma(1+1/q)^2;
            c2 = gamma(1+2/q);
            c  = c1/c2;
        end
        
        function mx = mxFunction(rho,txi,c)
            mx = sqrt((1-rho)*txi/c);
        end
        
        function my = myFunction(rho,txi,c)
            my = sqrt((1-rho)/(txi*c));
        end
        
    end
    
end
