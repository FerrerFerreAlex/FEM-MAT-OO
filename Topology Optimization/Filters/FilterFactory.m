classdef FilterFactory < handle
    
    methods (Access = public, Static)
        
        function filter = create(cParams)
            switch cParams.filterType
                case 'P1'
                    switch cParams.designVar.type                                                
                        case {'Density','MicroParams'}
                            filter = Filter_P1_Density(cParams);
                        case 'LevelSet'
                            filter = Filter_P1_LevelSet(cParams);
                    end
                case 'PDE'
                    switch cParams.designVar.type
                        case {'Density','MicroParams'}
                            filter = Filter_PDE_Density(cParams);
                        case 'LevelSet'
                            filter = Filter_PDE_LevelSet(cParams);
                    end
            end
        end
        
    end
    
end