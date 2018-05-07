classdef sk_tc_property_phase_content < sk_tc_property
%sk_func_get_main_phase: Child of sk_tc_property, class for evaluating the
%main phase for a given set of variables. 
%Result:    cellarray with name and content of the main phase.
    properties
        PhaseComparer='vpv';
        PhaseName='*';
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'Phase_Content'};
        %Names of properties which have to be calculated first
        DependsOn={}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_phase_content(pipe)
            ph = sk_tc_prop_result.getByType(pipe, 4);
            ph2 = sk_tc_prop_result.getByType(pipe, 5, {@ischar});
            
            if ~isempty(ph)
                obj.PhaseName = ph{1}.value;
                if ~isempty(ph2)
                    obj.PhaseComparer = ph2{1}.value;
                end
            else
                if length(ph2)==1
                    obj.PhaseName = ph2{1}.value;
                elseif length(ph2)>=2
                    obj.PhaseName = ph2{1}.value;
                    obj.PhaseComparer = ph2{2}.value;
                end
            end
            
        end
        
        function n = get.zNames(obj)
            n = sprintf('%s(%s)', obj.PhaseComparer, obj.PhaseName);
        end
        
        function res = calculate(obj, ~, eq, ~)
            n = obj.PhaseName;
            cnt = eq.GetValue('%s(%s)', obj.PhaseComparer, n);
            
            if strcmp(n, '*') || iscell(n)
                res = sk_tc_prop_result('Phase_Contents', 0, cnt(:,2));
            else
                res = sk_tc_prop_result(obj.zNames, 6, cnt);
            end
        end
    end
end