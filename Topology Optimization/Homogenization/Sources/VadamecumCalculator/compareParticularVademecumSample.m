classdef compareParticularVademecumSample < handle
    
    properties (Access = private)
        pNorms
        pNorm
        qNorms
        qNorm
        fileName
        volume
        volumes
        inclutionRatio
        
        vademecums
        monomials
        prefixName
        nonShearIndex
        Pcomp
        print
        legends
        plottingShearTerms
        
    end
    
    methods (Access = public)
        
        function obj = compareParticularVademecumSample()
            obj.init();
%             for ivolume = 1:length(obj.volumes)
%                 obj.volume = obj.volumes(ivolume);
%                 for iq = 1:length(obj.qNorms)
%                     obj.qNorm = obj.qNorms(iq);
%                     obj.computeSmoothRectangleSample();
%                     obj.computeRectangleSample();
%                 end
%             end
%             
            for ivolume = 1:length(obj.volumes)
                obj.volume = obj.volumes(ivolume);
                for ip = 1:length(obj.pNorms)
                    obj.pNorm = obj.pNorms(ip);
                    for iq = 1:length(obj.qNorms)
                        obj.qNorm = obj.qNorms(iq);
                        obj.computeSmoothRectanglePtensorSamples(iq);
                    end
                    obj.computeRectanglePtensorSamples();
                    obj.plotAmplificators();
                end
            end
        end
        
    end
    
    methods (Access = private)
        
        function init(obj)
            obj.pNorms = [2,4,8];
            obj.qNorms = [2,4,8,16,32];%[4,8,16,32];                        
            obj.volumes = 0.95;%0.95;%[0.7,0.95];%0.1;
            obj.inclutionRatio = 0.5;%1;%0.5;
            obj.plottingShearTerms = false;
        end
        
        function computeSmoothRectanglePtensorSamples(obj,iq)
            v = obj.computeSmoothPtensorSample();
            obj.vademecums{iq,1} = v;
        end
        
        function computeRectanglePtensorSamples(obj)
            v = obj.computeRectanglePtensorSample();
            nq = length(obj.qNorms);
            obj.vademecums{nq+1,1} = v;
        end
        
        function computeSmoothRectangleSample(obj)
            obj.fileName = 'SmoothRectangle';
            volumeStr = strrep(num2str(obj.volume),'.','');
            txiStr = strrep(num2str(obj.inclutionRatio),'.','');
            obj.prefixName = ['CaseOfStudy','Rho',volumeStr,'Txi',txiStr,'Q',num2str(obj.qNorm)];
            incLength = obj.findInclusionLengthForCertainVolume();
            obj.print = true;
            obj.computeCellVariables(incLength);
        end
        
        function v = computeSmoothPtensorSample(obj)
            obj.fileName = 'SmoothRectangle';
            volumeStr = strrep(num2str(obj.volume),'.','');
            txiStr = strrep(num2str(obj.inclutionRatio),'.','');            
            obj.prefixName = ['CaseOfStudy','Rho',volumeStr,'Txi',txiStr,'Q',num2str(obj.qNorm)];
            obj.print = true;
            v = obj.computePtensorVariables();
        end
        
        function v = computeRectanglePtensorSample(obj)
            obj.fileName = 'Rectangle';
            volumeStr = strrep(num2str(obj.volume),'.','');
            txiStr = strrep(num2str(obj.inclutionRatio),'.','');                        
            obj.prefixName = ['CaseOfStudy','Rho',volumeStr,'Txi',txiStr,'QInf'];
            obj.print = true;
            v = obj.computePtensorVariables();
        end
        
        function computeRectangleSample(obj)
            obj.fileName = 'Rectangle';
            volumeStr = strrep(num2str(obj.volume),'.','');
            obj.prefixName = ['CaseOfStudy','Rho',volumeStr,'QInf'];
            incLength = obj.computeInclusionLengthForRectangle();
            obj.computeCellVariables(incLength);
            %obj.checkSameVolume();
        end
        
        function computeCellVariables(obj,incLength)
            obj.computeVademecum(incLength);
            %v = obj.computePtensorVariables();
        end
        
        function computeVademecum(obj,incLength)
            d = obj.computeInputForVademecumCalculator(incLength);
            vc = VademecumCellVariablesCalculator(d);
            vc.computeVademecumData()
            vc.saveVademecumData();
        end
        
        function vd = computePtensorVariables(obj)
            d.fileName = [obj.prefixName,obj.fileName];
            d.pNorm = obj.pNorm;
            vc = VademecumPtensorComputer(d);
            vc.compute();
            vd = vc.vademecumData;
        end
        
        function d = computeInputForVademecumCalculator(obj,inclusionLength)
            d = SettingsVademecumCellVariablesCalculator();
            d.fileName   = [obj.prefixName,obj.fileName];
            d.freeFemFileName = obj.fileName;
            d.mxMin = inclusionLength*obj.inclutionRatio;
            d.mxMax = inclusionLength*obj.inclutionRatio;
            d.myMin = inclusionLength;
            d.myMax = inclusionLength;
            d.nMx   = 1;
            d.nMy   = 1;
            d.outPutPath = [];
            d.print = obj.print;
            d.freeFemSettings.hMax = 0.02;%0.0025;
            d.freeFemSettings.qNorm = obj.qNorm;
        end
        
        function m  = computeInclusionLengthForRectangle(obj)
            m = sqrt(1-obj.volume);
        end
        
        function checkSameVolume(obj)
            sVolume = obj.vademecums{1}.variables{1,1}.volume;
            rVolume = obj.vademecums{end}.variables{1,1}.volume;
            isequal = (sVolume - rVolume)/rVolume < 1e-3;
            if ~isequal
                error('not same volume')
            end
        end
        
        function plotAmplificators(obj)
            obj.obtainMonomials();
            obj.obtainNonShearTerms();
            obj.obtainPcomponents();
            obj.makePlot();
        end
        
        function makePlot(obj)
            fig = figure();
            y = obj.Pcomp(obj.nonShearIndex,:);
            ind = y<0;
            y = (abs(y).^(1/obj.pNorm));
            y(ind) = -y(ind);
            h = bar(y);
            allMonLegends = obj.computeAlphaLegend();
            monomialsLeg = allMonLegends(obj.nonShearIndex);
            set(gca, 'XTickLabel',monomialsLeg, 'XTick',1:numel(monomialsLeg));
            set(gca,'XTickLabelRotation',45);
            obj.createLegend();
            legend(obj.legends,'Interpreter','latex')
            p = barPrinter(fig,h);
            path = '/home/alex/Dropbox/Amplificators/Images/FourthOrderAmplificator/';
            volumeStr = strrep(num2str(obj.volume),'.','');
            plotName = ['Rho',volumeStr,'P',num2str(obj.pNorm)];
            if obj.plottingShearTerms
                plotName = [plotName,'WithShear'];
            end
            p.print([path,plotName]);
        end
        
        function obtainPcomponents(obj)
            nvad = size(obj.vademecums,1);
            obj.Pcomp = zeros(size(obj.monomials,1),nvad);
            for ivad = 1:nvad
                Ptensor = obj.vademecums{ivad,1}.variables{1,1}.Ptensor;
                obj.Pcomp(:,ivad) = Ptensor;
            end
        end
        
        function a = computeAlphaLegend(obj)
            for ia = 1:size(obj.monomials,1)
                a{ia} = mat2str(obj.monomials(ia,:));
            end
        end
        
        function obtainMonomials(obj)
            obj.monomials = obj.vademecums{1}.monomials;
        end
        
        function obtainNonShearTerms(obj)
            nMon = size(obj.monomials,1);
            obj.nonShearIndex = true(nMon,1);
            if ~obj.plottingShearTerms
                for ia = 1:nMon
                    mon = obj.monomials(ia,:);
                    obj.nonShearIndex(ia) = obj.hasNoShearComponent(mon);
                end
            end
        end
        
        function createLegend(obj)
            nQnorms = length(obj.qNorms);
            for ih = 1:nQnorms
                obj.legends{ih} = ['$q=',num2str(obj.qNorms(ih)),'$'];
            end
            obj.legends{nQnorms+1} = 'Rectangle';
        end
        
        function itHasNoShear = hasNoShearComponent(obj,monomial)
            shearIndeces = [3 4 5];
            itHasNoShear = ~any(monomial(shearIndeces));
        end
        
        function xroot = findInclusionLengthForCertainVolume(obj)
            obj.print = false;
            %x0 = [sqrt((1-obj.volume)/obj.inclutionRatio),0.99];            
            x0 = [0.1,0.99];
            problem.objective = @(x) obj.fzero(x);
            problem.x0 = x0;
            problem.solver = 'fzero';
            problem.options = optimset('Display','iter','TolX',1e-5);
            [xroot,~] = fzero(problem);
        end
        
        function f = fzero(obj,x)
            obj.computeCellVariables(x);
            vad = obj.computePtensorVariables;
            vol = vad.variables{1,1}.volume();
            f = (vol - obj.volume);
        end
        
    end
    
end