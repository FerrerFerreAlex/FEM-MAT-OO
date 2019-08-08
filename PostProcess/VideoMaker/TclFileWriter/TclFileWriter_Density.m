classdef TclFileWriter_Density < TclFileWriter
    
   methods (Access = public)
       
       function obj = TclFileWriter_Density(cParams)
           obj.tclTemplateName = 'Make_Video_density';   
           obj.fieldComponent = cParams.field.name;           
           obj.init(cParams);
       end
    
   end
       
end