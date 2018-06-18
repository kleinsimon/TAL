classdef sk_tc_property_eq < sk_tc_property

    properties (Access=private)
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'Equilibrium'};
        %Names of properties which have to be calculated first
        DependsOn={}; 
        SetBefore=1;
    end
    
    methods 
        function obj=sk_tc_property_eq(~)
            
        end
        
        function res = calculate(obj, ~, eq, ~)
            
            r = eq.Clone;
            
            res = sk_tc_prop_result(obj.zNames, 11, r);
        end
    end
end