classdef TclFileWriter_Density < TclFileWriter
    
   methods (Access = public)
       
       function obj = TclFileWriter_Density(cParams)
           obj.tclTemplateName = 'Make_Video_density';                                           
           obj.init(cParams);
           obj.fieldComponent = cParams.field.name;
       end
    
   end
       
end