classdef TclFileWriter_LevelSet < TclFileWriter
    
   methods (Access = public)
      
       function obj = TclFileWriter_LevelSet(cParams)
           obj.tclTemplateName = 'Make_Video_characteristic';                                
           obj.fieldComponent = cParams.field.name;           
           obj.init(cParams);
       end
    
   end
   

    
end