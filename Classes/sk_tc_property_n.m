classdef sk_tc_property_n < sk_tc_property
    properties
        Mole;
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'P'};
        %Names of properties which have to be calculated first
        DependsOn={}; 
        SetBefore=1;
    end
    
    methods 
        function obj=sk_tc_property_n(temp)
            if isa(temp{1}, 'sk_tc_prop_result')
                obj.Mole = temp{1};
            else
                obj.Mole = sk_tc_prop_result('Sys. Size', 9, temp{1}, 'mol');
            end
        end
        function res = calculate(obj, ~, ~, ~)
            
            res = obj.Mole;
        end
    end
end