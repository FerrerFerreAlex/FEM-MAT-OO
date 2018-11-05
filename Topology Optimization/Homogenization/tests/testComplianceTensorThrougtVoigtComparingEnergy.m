classdef testComplianceTensorThrougtVoigtComparingEnergy < test
    
    properties (Access = private)
        strain
        stress
        stiffTensor
        compTensor
        energyStiffTensProd
        energyCompTensProd        
    end
    
    methods (Access = public)
        
        function obj = testComplianceTensorThrougtVoigtComparingEnergy()
            obj.computeEnergies
        end
    end
    
    methods (Access = private)
        
        function computeEnergies(obj)            
            obj.generateStrain()
            obj.generateFourthOrderTensor()
            obj.computeStressTensor()
            obj.computeComplianceTensor()
            obj.computeEnergyByStifnessTensorProduct()   
            obj.computeEnergyByComplianceTensorProduct()
        end
        
        function generateStrain(obj)
            obj.strain = Strain3DTensor;
            obj.strain.createRandomTensor()
        end
        
        function generateFourthOrderTensor(obj)
            obj.stiffTensor = SymmetricFourthOrder3DTensor;
            obj.stiffTensor.createRandomTensor();
        end
        
        function computeStressTensor(obj)
            e = obj.strain;
            c = obj.stiffTensor;
            s = ProductComputer.compute(c,e);
            obj.stress = s;
        end
        
        function computeComplianceTensor(obj)
            obj.compTensor = SymmetricFourthOrder3DTensor();
            c = obj.stiffTensor;
            invC = Inverter.invert(c);
            obj.compTensor = invC;
        end
        
        function computeEnergyByComplianceTensorProduct(obj)
            s = obj.stress;
            invc = obj.compTensor;
            energy = EnergyComputer.compute(invc,s);
            obj.energyStiffTensProd = energy;
        end
        
        function computeEnergyByStifnessTensorProduct(obj)
            e = obj.strain;
            c = obj.stiffTensor;
            energy = EnergyComputer.compute(c,e);
            obj.energyCompTensProd = energy;
        end
        
    end
       
    methods (Access = protected)
       function hasPassed = hasPassed(obj)
           es = obj.energyStiffTensProd; 
           ec = obj.energyCompTensProd; 
           hasPassed = norm(es - ec) < 1e-12;
        end 
        
    end
    
end

