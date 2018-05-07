classdef sk_tc_property_phase < sk_tc_property

    properties (Access=private)
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'PhaseComp'};
        %Names of properties which have to be calculated first
        DependsOn={}; 
        SetBefore=1;
        PhaseName;
    end
    
    methods 
        function obj=sk_tc_property_phase(PhaseName)
            obj.PhaseName=PhaseName;
        end
        
        function res = calculate(obj, ~, eq, ~)
            pn=eq.ParsePhaseName(obj.PhaseName{1});
            r=eq.GetValue('x(%s,*)', pn);
            r(:,1)=strrep(r(:,1), [pn ','], '');
            %neq = eq.GetLocalState(obj.PhaseName{1});
            
            res = sk_tc_prop_result(obj.zNames, 2, r);
        end
    end
end