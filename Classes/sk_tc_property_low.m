classdef sk_tc_property_low < sk_tc_property

    properties (Access=private)
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'LowComp'};
        %Names of properties which have to be calculated first
        DependsOn={'scheil_range'}; 
        SetBefore=1;
    end
    
    methods 
        function obj=sk_tc_property_low(~)
            
        end
        
        function res = calculate(obj, ~, ~, deps)
            
            r=deps{1};
            
            res = sk_tc_prop_result(obj.zNames, 2, r.value{2});
        end
    end
end