classdef sk_tc_property_cplusn < sk_tc_property
% sk_tc_property_cplusn: Child of sk_funcs. Evaluates the Sum of C and N.
% By default, the weight-content is returned.

    properties
        Property = 'w'; %Variable to measure the content. Defaults to "W".
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'C+N'};
        %Names of properties which have to be calculated first
        DependsOn={}; 
        SetBefore=1;
    end
    
    methods
        function obj = sk_tc_property_cplusn(~)
            
        end
        function r = get.zNames(obj)
            r = sprintf('%s(c+n)', obj.Property);
        end
        
        function res = calculate(obj, ~,  eq, ~)
            cn = eq.GetValue('%s(c)', obj.Property) + eq.GetValue('%s(n)', obj.Property);
            res = sk_tc_prop_result(obj.zNames, 6, cn);
        end
    end
end