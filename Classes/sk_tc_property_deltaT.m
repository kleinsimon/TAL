classdef sk_tc_property_deltaT < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Evaluates the ac1 temperature of
% steels. 
%
%   StartT:     Starting temperature. This temperature must be above AC1.
%               Defaults to 1100K. If no major fcc phase is found, t is
%               raised until MaxT (1250K). 
%   Result:     AC1 in K
    properties

    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'deltaT'};
        %Names of properties which have to be calculated first
        DependsOn={'tliq'}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_deltaT(~)
            
        end
        function res = calculate(obj, ~, eq, deps)
            t=deps{1}.value;
                
            try
                eq.SetCondition('t', t-1);
            
                phs = eq.GetStablePhases;
                i = find(contains(phs, 'BCC', 'IgnoreCase', 1), 1);
                
                if isempty(i)
                    warning('! No Delta Ferrite found\n');
                    res=nan;
                    return;
                end
                
                res = sk_tc_prop_result(obj.zNames, 1, t-1, 'K');
            catch
                res = nan;
            end
        end
    end
end