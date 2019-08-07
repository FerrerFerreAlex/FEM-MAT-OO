classdef TclFileWriter_StandardField < TclFileWriter
    
   methods (Access = public)
       
       function obj = TclFileWriter_StandardField(cParams)
           obj.tclTemplateName = 'Make_Video_standardField';                                           
           obj.init(cParams);
           obj.fieldComponent = cParams.field.component;
       end
    
   end   
    
end