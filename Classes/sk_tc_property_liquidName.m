classdef sk_tc_property_liquidName < sk_tc_property
% sk_tc_property_deltaName: Returns the name of the delta ferrite phase.
% UNSTABLE.

    properties
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'liquidName'};
        %Names of properties which have to be calculated first
        DependsOn={}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_liquidName(~)
            
        end
        function res = calculate(obj, ~, eq, ~)
                
            try
                eq.SetCondition('t', 3000);
            
                liquidName = eq.GetMainPhase;
            
                res = sk_tc_prop_result(obj.zNames, 4, liquidName);
            catch
                res = nan;
            end
        end
    end
end