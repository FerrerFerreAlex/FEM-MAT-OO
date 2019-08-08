classdef TclFileWriter_StandardField < TclFileWriter
    
   methods (Access = public)
       
       function obj = TclFileWriter_StandardField(cParams)
           obj.tclTemplateName = 'Make_Video_standardField'; 
           obj.fieldComponent = cParams.field.component;           
           obj.init(cParams);
       end
    
   end   
    
end