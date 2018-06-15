classdef sk_tc_property_deltaName < sk_tc_property
% sk_tc_property_deltaName: Returns the name of the delta ferrite phase.
% UNSTABLE.

    properties
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