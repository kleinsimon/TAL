classdef sk_tc_property_deltaName < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Evaluates the ac1 temperature of
% steels. 
%
%   StartT:     Starting temperature. This temperature must be above AC1.
%               Defaults to 1100K. If no major fcc phase is found, t is
%               raised until MaxT (1250K). 
%   Result:     AC1 in K
    properties
        Verbose=1;
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'deltaName'};
        %Names of properties which have to be calculated first
        DependsOn={'deltaT'}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_deltaName(~)
            
        end
        function res = calculate(obj, ~, eq, deps)
            t=deps{1}.value;
                
            try
                eq.SetCondition('t', t);
            
                phs = eq.GetStablePhases;
                i = find(contains(phs, 'BCC', 'IgnoreCase', 1),1);
                deltaName = phs{i};
            
                res = sk_tc_prop_result(obj.zNames, 4, deltaName);
            catch
                res = nan;
            end
        end
    end
end