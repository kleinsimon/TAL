classdef sk_tc_property_mainphase < sk_tc_property
%sk_func_get_main_phase: Child of sk_tc_property, class for evaluating the
%main phase for a given set of variables. 
%Result:    cellarray with name and content of the main phase.
    properties
        AllowedPhases = {'fcc_a1','bcc_a2'};
        PhaseComparer='vpv';
        SetTemp;
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'Main_Phase'};
        %Names of properties which have to be calculated first
        DependsOn={}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_mainphase(~)
            
        end
        function res = calculate(obj, caller, eq, deps)
            try
                name = eq.GetMainPhase(obj.PhaseComparer,obj.AllowedPhases);
            catch
                res = nan;
                return;
            end
            res = sk_tc_prop_result(obj.zNames, 4, name);
        end
    end
end