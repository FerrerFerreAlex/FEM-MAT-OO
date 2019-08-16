classdef ShFunc_StressNorm < ShFunWithElasticPdes
    
    properties (Access = private)
        adjointProb
        fAdjoint
        Rsig
        RsigV
        Reps
        RepsV
        rStress
        rStrain
        rStrainAdjoint
    end
    
    methods (Access = public)
        
        function obj = ShFunc_StressNorm(cParams)
            cParams.filterParams.quadratureOrder = 'LINEAR';
            obj.init(cParams);
            fileName = cParams.femSettings.fileName;
            obj.createEquilibriumProblem(fileName);
            obj.createAdjointProblem(fileName);
            obj.createOrientationUpdater();
        end
        
        function f = getPhysicalProblems(obj)
            f{1} = obj.physicalProblem;
            f{2} = obj.adjointProb;
        end
        
    end
    
    methods (Access = protected)
               
        function t = Tfactor(obj,i,j)
            tv = [1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1];
            t = tv(i,j);
        end
        
        function c = computeFunctionValue(obj)
            obj.rotateStressAndStrain();            
            dvolum = obj.physicalProblem.geometry.dvolu;
            ngaus  = obj.physicalProblem.element.quadrature.ngaus;
            P  = obj.homogenizedVariablesComputer.PrefVector;
            monom = obj.homogenizedVariablesComputer.monomials;            
            alpha = monom;
            stress = obj.rStress;
            nt = 6;
            ns = 6;
            c = 0;
            for igaus = 1:ngaus
                stressG = squeeze(stress(igaus,:,:));
                dV = dvolum(:,igaus);
                for t = 1:nt
                    sigmaA = ones(size(stressG,2),1);
                    for s = 1:ns
                        Ast = alpha(t,s);
                        [i,j] = obj.index(s);
                        si(:,1) = squeeze(stressG(i,:));
                        sj(:,1) = squeeze(stressG(j,:));
                        stress2 = si.*sj;
                        nSigma = stress2.^Ast;
                        sigmaA = sigmaA.*nSigma;
                    end
                    Pt(:,1) = P(t,:);
                    c = c + sum(Pt.*sigmaA.*dV);
                end
            end
            obj.value = c;
        end
        
        function [i,j] = index(obj,s)
            T = [1 1;
                2 2;
                3 3;
                2 3;
                1 3;
                1 2];
            i = T(s,1);
            j = T(s,2);
        end
        
        
        function updateHomogenizedMaterialProperties(obj)
            obj.filterDesignVariable();
            obj.homogenizedVariablesComputer.computeCtensor(obj.regDesignVariable);
            obj.homogenizedVariablesComputer.computePtensor(obj.regDesignVariable);
            obj.homogenizedVariablesComputer.computePtensorVector(obj.regDesignVariable);
        end
        
        function computeGradient(obj)
            obj.rotateStressAndStrain();
            %g1b = obj.computeFirstTerm();
            g1 = obj.computeFirstTerm2();
            %g2b = obj.computeSecondTerm();
            g2 = obj.computeSecondTerm2();
            g3 = obj.computeThirdTerm();
            g = g1 + g2 + g3;
            gf = zeros(size(obj.Msmooth,1),obj.nVariables);
            for ivar = 1:obj.nVariables
                gs = squeeze(g(:,:,ivar));
                gf(:,ivar) = obj.filter.getP1fromP0(gs);
            end
            g = obj.Msmooth*gf;
            obj.gradient = g(:);
        end
        
        
        function solvePDEs(obj)
            obj.physicalProblem.setC(obj.homogenizedVariablesComputer.C);
            obj.physicalProblem.computeVariables();
            %obj.computeFadjoint();
            obj.computeFadjoint2();
            obj.adjointProb.setC(obj.homogenizedVariablesComputer.C);
            obj.adjointProb.computeVariablesWithBodyForces(obj.fAdjoint);
        end
        
        function updateGradient(obj)
            
            
        end
    end
    
    methods (Access = private)
        
        function createAdjointProblem(obj,fileName)
            obj.adjointProb = FEM.create(fileName);
            obj.adjointProb.preProcess;
        end
        
        function createRotators(obj)
            S = StressPlaneStressVoigtTensor();
            alpha = sym('alpha','real');
            v = Vector3D();
            v.setValue([0 0 1]);
            factory = RotatorFactory();
            rot = factory.create(S,alpha,v);
            obj.Rsig = rot.rotationMatrix();
            obj.Reps = simplify(inv(obj.Rsig)');
        end
        
        function evaluateRotators(obj)
            obj.RsigV = obj.evaluateRotator(obj.Rsig);
            obj.RepsV = obj.evaluateRotator(obj.Reps);
        end
        
        function Rv = evaluateRotator(obj,R)
            Rsym = R;
            dir = obj.designVariable.alpha;
            nx = squeeze(dir(1,:));
            ny = squeeze(dir(2,:));
            angle = squeeze(atan2(ny,nx));
            Rv = zeros(3,3,length(angle));
            for i = 1:3
                for j = 1:3
                    rij = matlabFunction(Rsym(i,j));
                    Rv(i,j,:) = rij(angle);
                end
            end
        end
        
        function rotateStress(obj)
            stress  = obj.physicalProblem.variables.stress;
            obj.rStress = obj.rotateField(stress,obj.RsigV);
        end
        
        function rotateStrain(obj)
            strain = obj.physicalProblem.variables.strain;
            obj.rStrain = obj.rotateField(strain,obj.RepsV);
        end
        
        function rotateStrainAdjoint(obj)
            strain = obj.adjointProb.variables.strain;
            obj.rStrainAdjoint = obj.rotateField(strain,obj.RepsV);
        end
        
        function rTensor = rotateField(obj,tensor,R)
            rTensor = zeros(size(tensor));
            ngaus = size(tensor,1);
            nstres = size(tensor,2);
            for igaus = 1:ngaus
                for i = 1:nstres
                    for j = 1:nstres
                        rTensor(igaus,i,:) = rTensor(igaus,i,:) + R(i,j,:).*tensor(igaus,j,:);
                    end
                end
            end
        end
        
        function rotateStressAndStrain(obj)
            obj.createRotators();
            obj.evaluateRotators();
            obj.rotateStress();
            obj.rotateStrain();
            obj.rotateStrainAdjoint();
        end
        
        
        function g = computeFirstTerm(obj)
            nelem = obj.physicalProblem.geometry.interpolation.nelem;
            ngaus = obj.physicalProblem.element.quadrature.ngaus;
            nstre = obj.physicalProblem.element.getNstre();
            eu = obj.rStrain;
            su = obj.rStress;
            dC = obj.homogenizedVariablesComputer.dCref;
            P  = obj.homogenizedVariablesComputer.Pref;
            
            g = zeros(nelem,ngaus,obj.nVariables);
            for igaus = 1:ngaus
                for istre = 1:nstre
                    ei   = squeeze(eu(igaus,istre,:));
                    for jstre = 1:nstre
                        for ivar = 1:obj.nVariables
                            dCij_iv = squeeze(dC(istre,jstre,ivar,:));
                            for kstre = 1:nstre
                                Pjk  = squeeze(P(jstre,kstre,:));
                                sk   = squeeze(su(igaus,kstre,:));
                                g_iv = squeeze(g(:,igaus,ivar));
                                g(:,igaus,ivar) = g_iv + 2*ei.*dCij_iv.*Pjk.*sk;
                            end
                        end
                    end
                end
            end
        end
        
        function g = computeFirstTerm2(obj)
            nstre = obj.physicalProblem.element.getNstre();
            nelem = obj.physicalProblem.geometry.interpolation.nelem;
            ngaus  = obj.physicalProblem.element.quadrature.ngaus;
            strain = obj.rStrain;
            stress = obj.rStress;
            dC = obj.homogenizedVariablesComputer.dCref;
            P  = obj.homogenizedVariablesComputer.PrefVector;
            monom = obj.homogenizedVariablesComputer.monomials;
            alpha = monom;
            nt = 6;
            ns = 6;
            nr = 6;
            g = zeros(nelem,ngaus,obj.nVariables);
            for ivar = 1:obj.nVariables
                for igaus = 1:ngaus
                    stressG = squeeze(stress(igaus,:,:));
                    strainG = squeeze(strain(igaus,:,:));
                    for t = 1:nt
                        dSdMt = zeros(size(stressG,2),1);
                        for r = 1:nr
                            sigmaA = ones(size(stressG,2),1);
                            Atr = alpha(t,r);
                            if Atr > 0
                                for s = 1:ns
                                    Ast = alpha(t,s);
                                    if Ast > 0
                                        if r == s
                                            drs = 1;
                                        else
                                            drs = 0;
                                        end
                                        [istre,jstre] = obj.index(s);
                                        si(:,1) = squeeze(stressG(istre,:));
                                        sj(:,1) = squeeze(stressG(jstre,:));
                                        stress2 = si.*sj;
                                        nSigma = stress2.^(Ast-drs);
                                        
                                        
                                        
                                        sigmaA = sigmaA.*nSigma;
                                    end
                                end
                                
                                [istre,jstre] = obj.index(r);
                                si(:,1) = squeeze(stressG(istre,:));
                                sj(:,1) = squeeze(stressG(jstre,:));                                
                                
                                dsigma = zeros(nelem,1);
                                for lstre = 1:nstre
                                    el(:,1) = squeeze(strainG(lstre,:));
                                    dCil_iv = squeeze(dC(istre,lstre,ivar,:));
                                    dCjl_iv = squeeze(dC(jstre,lstre,ivar,:));
                                    dsigma  = dsigma + (sj.*dCil_iv + si.*dCjl_iv).*el;
                                end
                                
                                sigmaA = sigmaA.*dsigma;
                                
                            end
                            dSdMt = dSdMt + Atr*sigmaA;
                        end
                        giv = squeeze(g(:,igaus,ivar));
                        Pt(:,1) = squeeze(P(t,:));
                        g(:,igaus,ivar) = giv + Pt.*dSdMt;
                    end
                end
            end
        end
        
        function g = computeSecondTerm(obj)
            nelem = obj.physicalProblem.geometry.interpolation.nelem;
            ngaus = obj.physicalProblem.element.quadrature.ngaus;
            nstre = obj.physicalProblem.element.getNstre();
            su = obj.rStress;
            dP  = obj.homogenizedVariablesComputer.dPref;
            g = zeros(nelem,ngaus,obj.nVariables);
            for igaus = 1:ngaus
                for istre = 1:nstre
                    si   = squeeze(su(igaus,istre,:));
                    for ivar = 1:obj.nVariables
                        for kstre = 1:nstre
                            sk = squeeze(su(igaus,kstre,:));
                            dPik_iv  = squeeze(dP(istre,kstre,ivar,:));
                            g_iv  = squeeze(g(:,igaus,ivar));
                            g(:,igaus,ivar) = g_iv + si.*dPik_iv.*sk;
                        end
                    end
                end
            end
        end
        
        function g =  computeSecondTerm2(obj)
            nelem = obj.physicalProblem.geometry.interpolation.nelem;
            dvolum = obj.physicalProblem.geometry.dvolu;
            ngaus  = obj.physicalProblem.element.quadrature.ngaus;
            dP     = obj.homogenizedVariablesComputer.dPrefVector;
            monom = obj.homogenizedVariablesComputer.monomials;
            alpha = monom;
            stress = obj.rStress;
            nt = 6;
            ns = 6;
            g = zeros(nelem,ngaus,obj.nVariables);
            for igaus = 1:ngaus
                stressG = squeeze(stress(igaus,:,:));
                dV = dvolum(:,igaus);
                for t = 1:nt
                    sigmaA = ones(size(stressG,2),1);
                    for s = 1:ns
                        Ast = alpha(t,s);
                        [i,j] = obj.index(s);
                        si(:,1) = squeeze(stressG(i,:));
                        sj(:,1) = squeeze(stressG(j,:));
                        stress2 = si.*sj;
                        nSigma = stress2.^Ast;
                        sigmaA = sigmaA.*nSigma;
                    end
                    
                    for ivar = 1:obj.nVariables
                        dPt(:,1) = dP(t,ivar,:);
                        g_iv  = squeeze(g(:,igaus,ivar));
                        g(:,igaus,ivar) = g_iv + dPt.*sigmaA;
                    end
                    
                end
            end
        end
        
        
        
        function g = computeThirdTerm(obj)
            nelem = obj.physicalProblem.geometry.interpolation.nelem;
            ngaus = obj.physicalProblem.element.quadrature.ngaus;
            nstre = obj.physicalProblem.element.getNstre();
            eu = obj.rStrain;
            dC = obj.homogenizedVariablesComputer.dCref;
            ep = obj.rStrainAdjoint;
            
            
            g = zeros(nelem,ngaus,obj.nVariables);
            for igaus = 1:ngaus
                for istre = 1:nstre
                    ei   = squeeze(eu(igaus,istre,:));
                    for jstre = 1:nstre
                        ej   = squeeze(ep(igaus,jstre,:));
                        for ivar = 1:obj.nVariables
                            dCij_iv = squeeze(dC(istre,jstre,ivar,:));
                            g_iv  = squeeze(g(:,igaus,ivar));
                            g(:,igaus,ivar) = g_iv + ei.*dCij_iv.*ej;
                        end
                    end
                end
            end
        end
        
        function computeFadjoint2(obj)
            obj.createRotators();
            obj.evaluateRotators();
            obj.rotateStress();
            nstre = obj.physicalProblem.element.getNstre();
            nelem  = obj.physicalProblem.geometry.interpolation.nelem;
            ngaus  = obj.physicalProblem.element.quadrature.ngaus;
            phy    = obj.physicalProblem;
            dvolum = phy.geometry.dvolu;
            nnode = phy.element.nnode;
            nunkn = phy.element.dof.nunkn;
            stress = obj.rStress;
            P  = obj.homogenizedVariablesComputer.PrefVector;
            C = obj.homogenizedVariablesComputer.Cref;
            monom = obj.homogenizedVariablesComputer.monomials;
            alpha = monom;
            nt = 6;
            ns = 6;
            nr = 6;
            eforce = zeros(nunkn*nnode,ngaus,nelem);
            for iv = 1:nnode*nunkn
                for igaus = 1:ngaus
                    Bmat = phy.element.computeB(igaus);
                    BmatR = obj.rotateB(Bmat);
                    dV(:,1) = dvolum(:,igaus);
                    stressG = squeeze(stress(igaus,:,:));
                    for t = 1:nt
                        dSdMt = zeros(size(stressG,2),1);
                        for r = 1:nr
                            sigmaA = ones(size(stressG,2),1);
                            Atr = alpha(t,r);
                            if Atr > 0
                                for s = 1:ns
                                    Ast = alpha(t,s);
                                    if Ast > 0
                                        if r == s
                                            drs = 1;
                                        else
                                            drs = 0;
                                        end
                                        [istre,jstre] = obj.index(s);
                                        si(:,1) = squeeze(stressG(istre,:));
                                        sj(:,1) = squeeze(stressG(jstre,:));
                                        stress2 = si.*sj;
                                        nSigma = stress2.^(Ast-drs);
                                        

                                        
                                        sigmaA = sigmaA.*nSigma;
                                    end
                                end
                                
                                        [istre,jstre] = obj.index(r);
                                        si(:,1) = squeeze(stressG(istre,:));
                                        sj(:,1) = squeeze(stressG(jstre,:));                                
                                
                                        dsigma = zeros(nelem,1);
                                        for lstre = 1:nstre
                                            Cil_iv = squeeze(C(istre,lstre,:));
                                            Cjl_iv = squeeze(C(jstre,lstre,:));
                                            Bl_iv = squeeze(BmatR(lstre,iv,:));
                                            dsigma = dsigma + (sj.*Cil_iv + si.*Cjl_iv).*Bl_iv;
                                        end                                
                                
                                sigmaA = sigmaA.*dsigma;
                                
                            end
                            dSdMt = dSdMt + Atr*sigmaA;
                        end
                        Fiv = squeeze(eforce(iv,igaus,:));
                        Pt(:,1) = squeeze(P(t,:));
                        eforce(iv,igaus,:) = Fiv - Pt.*dSdMt.*dV;
                    end
                end
                
                
            end
            Fvol = phy.element.AssembleVector({eforce});
            obj.fAdjoint = Fvol;
        end
        
        function computeFadjoint(obj)
            obj.createRotators();
            obj.evaluateRotators();
            obj.rotateStress();
            phy    = obj.physicalProblem;
            dvolum = phy.geometry.dvolu;
            stress = obj.rStress;
            P = obj.homogenizedVariablesComputer.Pref;
            C = obj.homogenizedVariablesComputer.Cref;
            ngaus = phy.element.quadrature.ngaus;
            nstre = size(stress,2);
            nelem = size(stress,3);
            nnode = phy.element.nnode;
            nunkn = phy.element.dof.nunkn;
            
            PC = zeros(size(C));
            for istre = 1:nstre
                for jstre = 1:nstre
                    for kstre = 1:nstre
                        PC(istre,jstre,:) = PC(istre,jstre,:) + P(istre,kstre,:).*C(kstre,jstre,:);
                    end
                end
            end
            
            eforce = zeros(nunkn*nnode,ngaus,nelem);
            for igaus = 1:ngaus
                Bmat = phy.element.computeB(igaus);
                BmatR = obj.rotateB(Bmat);
                stressG = squeeze(stress(igaus,:,:));
                dV(:,1) = dvolum(:,igaus);
                for istre = 1:nstre
                    si(:,1) = squeeze(stressG(istre,:));
                    for jstre = 1:nstre
                        PCij = squeeze(PC(istre,jstre,:));
                        for iv = 1:nnode*nunkn
                            Bj_iv = squeeze(BmatR(jstre,iv,:));
                            int = -2*si.*PCij.*Bj_iv;
                            Fiv = squeeze(eforce(iv,igaus,:));
                            eforce(iv,igaus,:) = Fiv + int.*dV;
                        end
                    end
                end
            end
            Fvol = phy.element.AssembleVector({eforce});
            obj.fAdjoint = Fvol;
        end
        
        function Br = rotateB(obj,B)
            R = obj.RepsV;
            Br = zeros(size(B));
            nstre = size(R,1);
            nv = size(B,2);
            for istre = 1:nstre
                for jstre = 1:nstre
                    for iv = 1:nv
                        Br(istre,iv,:) =  Br(istre,iv,:) + R(istre,jstre,:).*B(jstre,iv,:);
                    end
                end
            end
        end
        
        
    end
    
end
