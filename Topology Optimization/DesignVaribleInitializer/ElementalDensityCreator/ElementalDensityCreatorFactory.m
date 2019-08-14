classdef ElementalDensityCreatorFactory < handle
    
    
   methods (Access = public, Static)
              
       function e = create(cParams)
            switch cParams.type
                case 'ElementalDensityCreatorByLevelSetCreator'
                    e = EdcByLevelSetCreator(cParams);
                case 'ElementalDensityCreatorByLevelSet'
                    e = EdcByLevelSet(cParams);
                case 'EdcExplicit'
            end              
       end
       
       function p = createPrinters(type)
           switch type
               case 'ElementalDensityCreatorByLevelSetCreator'
                   p = {'DensityGauss','LevelSet'};
               case 'ElementalDensityCreatorByLevelSet'
                   p = {'DensityGauss','LevelSet'};
               case 'EdcExplicit'
                   p = {'DensityGauss'};                   
           end                      
       end
       
       
   end
    
    
end