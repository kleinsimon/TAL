classdef sk_func_get_main_phase < sk_funcs
%sk_func_get_main_phase: Child of sk_funcs, class for evaluating the
%main phase for a given set of variables. 
%Result:    cellarray with name and content of the main phase.
    properties
        zNames = {'content','mainphase'};
        AllowedPhases = {'fcc_a1','bcc_a2'};
        PhaseComparer='vpv';
        BaseEq=[];
    end
    
    methods 
        function obj = sk_func_get_main_phase(eq)
            obj.BaseEq=eq;
            if ~isa(obj.BaseEq, 'sk_tc_equilibrium')
                error('Must set BaseEQ first');
            end
        end
        function res = calculate(obj, vars, values )
            eq=obj.BaseEq;
            eq.StartSandbox;
            eq.SetConditionsForComponents(vars, values);

            [name, cnt] = eq.GetMainPhase(obj.PhaseComparer,obj.AllowedPhases);
            res = {cnt, name};
            eq.EndSandbox;
        end
    end
    
    methods (Static)
        %sk_func_get_main_phase.get() Returns the active main-phase (greatest vol-%)
        function res = get(eq)
            slv = sk_func_get_main_phase(eq);
            res = slv.calculate({},[]);
        end
    end
end