classdef sk_tc_property_cplusn < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Evaluates the ac1 temperature of
% steels. 
%
%   StartT:     Starting temperature. This temperature must be above AC1.
%               Defaults to 1100K. If no major fcc phase is found, t is
%               raised until MaxT (1250K). 
%   Result:     AC1 in K
    properties
        Property = 'w';
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