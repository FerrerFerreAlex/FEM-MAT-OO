classdef TensorPrinter < FieldPrinter ...
                       & GaussFieldPrinter
  
    
    properties (Access = private)
       fieldComponentName
    end
    
    properties (Access = protected)
        gaussDescriptor
    end
    
    methods (Access = public)
        
        function obj = TensorPrinter(fileID,fieldComponentName,fieldValues,fieldName,istep,fieldPosition,gaussDescriptor)
            obj.fieldType = 'Vector';
            obj.init(fileID,fieldComponentName,fieldValues,fieldName,istep,fieldPosition,gaussDescriptor);
            obj.print();
        end
        
    end
    
    methods (Access = protected)
        
        function init(obj,fileID,fieldComponentName,fieldValues,fieldName,istep,fieldPosition,gaussDescriptor)
            obj.fileID             = fileID;
            obj.fieldComponentName = fieldComponentName;
            obj.fieldValues        = fieldValues;
            obj.fieldName          = fieldName;
            obj.istep              = istep;
            obj.fieldPosition      = fieldPosition;
            obj.gaussDescriptor    = gaussDescriptor;
        end
        
        function print(obj)
            obj.printResultsLineHeader();
            obj.printComponentNamesLine();
            obj.printValuesLine();
            obj.printFieldLines();
            obj.printEndValuesLine();
        end
        
        function printFieldLines(obj)
            iD = obj.fileID;
            fV = obj.fieldValues;
            for ielem = 1:size(fV,3)
                fprintf(iD,'%6.0f ',ielem);
                for igaus = 1:size(fV,1)
                    for istre = 1:size(fV,2)
                        fprintf(iD,'%12.5d ',fV(igaus,istre,ielem));
                    end
                    fprintf(iD,'\n');
                end
            end
        end
        
       function printComponentNamesLine(obj)
            iD = obj.fileID;
            fC = obj.fieldComponentName;    
            ndim = size(obj.fieldValues,2);
            switch ndim
                case 4
                 fprintf(iD,'ComponentNames  "%sx", "%sy", "%sxy", "%sz"\n',fC,fC,fC,fC);
                case 6
                 fprintf(iD,'ComponentNames "%sx", "%sy", "%sz", "%sxy", "%syz", "%sxz"\n',fC,fC,fC,fC,fC,fC);
            end
       end
       
    end
    
end

