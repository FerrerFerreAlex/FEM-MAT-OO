classdef HomogenizedVarComputerFromVademecum ...
        < HomogenizedVarComputer
    
    properties (Access = public)
        Ctensor
        density
        Ptensor
        PtensorVector        
        Cref
        dCref        
        Pref
        dPref   
        PrefVector
        dPrefVector
        RepsV
        monomials        
    end
    
    properties (Access = private)
       Reps      
       Rsig
       RsigV
       %Cref
       %dCref
       rotator
       %Pref
       %dPref
    end
    
    methods (Access = public)
        
        function obj = HomogenizedVarComputerFromVademecum(cParams)
            s = cParams.vademecumVariablesLoaderSettings;
            s.targetParams = cParams.targetParams;
            s.targetSettings = cParams.targetSettings;
            v = VademecumVariablesLoader(s);
            v.load();
            obj.Ctensor = v.Ctensor;
            obj.Ptensor = v.Ptensor;
            obj.density = v.density;
            obj.PtensorVector = v.PtensorVector;
            obj.computeSymbolicRotationMatrix();
            obj.designVariable = cParams.designVariable;
            obj.rotator = ConstitutiveTensorRotator();            
        end
        
        function computeCtensor(obj,x)
            obj.obtainReferenceConsistutiveTensor(x);            
            obj.computeRepsMatrix();
            obj.rotateConstitutiveTensor();
        end
        
        function computePtensor(obj,x)
            obj.obtainReferenceAmplificatorTensor(x);            
            obj.computeRsigMatrix();
            obj.rotateAmplificatorTensor();            
        end
        
        function computePtensorVector(obj,x)
            obj.obtainReferenceAmplificatorTensorVector(x);
            obj.monomials = obj.PtensorVector.getMonomials();
        end        
        
        function computeDensity(obj,x)
            mx = x(:,1);
            my = x(:,2);
            [rho,drho] = obj.density.compute([mx,my]);
            obj.rho = rho;
            obj.drho = drho;
        end        
        
        function rho = calculateDensity(obj,x)
            mx = x(:,1);
            my = x(:,2);
            [rho,~] = obj.density.compute([mx,my]);            
        end
        
    end
    
    methods (Access = private)
                
        function obtainReferenceConsistutiveTensor(obj,x)
            mx = x(:,1);
            my = x(:,2);
            [c,dc] = obj.Ctensor.compute([mx,my]);
            obj.Cref  = c;
            obj.dCref = permute(dc,[1 2 4 3]);            
        end        
        
        function obtainReferenceAmplificatorTensor(obj,x)
            mx = x(:,1);
            my = x(:,2);
            [p,dp] = obj.Ptensor.compute([mx,my]);
            obj.Pref  = p;
            obj.dPref = permute(dp,[1 2 4 3]);            
        end    
        
        function obtainReferenceAmplificatorTensorVector(obj,x)
            mx = x(:,1);
            my = x(:,2);
            [p,dp] = obj.PtensorVector.compute([mx,my]);
            obj.PrefVector  = p;
            obj.dPrefVector = permute(dp,[1 3 2]);            
        end             
        
        function computeRepsMatrix(obj)
            Rsym = obj.Reps;
            dir = obj.designVariable.alpha;            
            nx = squeeze(dir(1,:));
            ny = squeeze(dir(2,:));
            angle = squeeze(atan2(ny,nx));
            R = zeros(3,3,length(angle));
            for i = 1:3
                for j = 1:3
                    rij = matlabFunction(Rsym(i,j));
                    R(i,j,:) = rij(angle);
                end
            end
            obj.RepsV = R;
        end        
        
        function computeRsigMatrix(obj)
            Rsym = obj.Rsig;
            dir = obj.designVariable.alpha;            
            nx = squeeze(dir(1,:));
            ny = squeeze(dir(2,:));
            angle = squeeze(atan2(ny,nx));
            R = zeros(3,3,length(angle));
            for i = 1:3
                for j = 1:3
                    rij = matlabFunction(Rsym(i,j));
                    R(i,j,:) = rij(angle);
                end
            end
            obj.RsigV = R;
        end              
        
        function rotateConstitutiveTensor(obj)
            cr  = obj.Cref;    
            dCr = obj.dCref;
            c = obj.rotator.rotate(cr,obj.RepsV);
            dc(:,:,1,:) = obj.rotator.rotate(squeeze(dCr(:,:,1,:)),obj.RepsV);
            dc(:,:,2,:) = obj.rotator.rotate(squeeze(dCr(:,:,2,:)),obj.RepsV);     
            obj.C = c;
            obj.dC = dc;               
        end
  
        function rotateAmplificatorTensor(obj)
            pr  = obj.Pref;    
            dPr = obj.dPref;
            p = obj.rotator.rotate(pr,obj.RsigV);
            dp(:,:,1,:) = obj.rotator.rotate(squeeze(dPr(:,:,1,:)),obj.RsigV);
            dp(:,:,2,:) = obj.rotator.rotate(squeeze(dPr(:,:,2,:)),obj.RsigV);     
            obj.P = p;
            obj.dP = dp;               
        end        
        
        function a = computeSymbolicRotationMatrix(obj)
            S = StressPlaneStressVoigtTensor();
            alpha = sym('alpha','real');
            v = Vector3D();
            v.setValue([0 0 1]);
            factory = RotatorFactory();
            rot = factory.create(S,alpha,v);
            a = rot.rotationMatrix();  
            obj.Rsig = a;
            obj.Reps = simplify(inv(a)');
        end
        
    end
    
end