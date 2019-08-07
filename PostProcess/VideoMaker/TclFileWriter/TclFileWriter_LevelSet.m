classdef TclFileWriter_LevelSet < TclFileWriter
    
   methods (Access = public)
      
       function obj = TclFileWriter_LevelSet(cParams)
           obj.tclTemplateName = 'Make_Video_characteristic';                                
           obj.init(cParams);
           obj.fieldComponent = cParams.field.name;
       end
    
   end
   

    
end