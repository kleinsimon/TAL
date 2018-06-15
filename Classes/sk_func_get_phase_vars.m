classdef sk_func_get_phase_vars < sk_funcs
%%sk_func_get_phase_vars: Child of sk_funcs, class for evaluating the
%Variables for all components in a phase.
%
%   Variables_TC:   Cellarray of variables to get for the phase
%   Phase:          Phase to Investigate. Leave empty to look into main Phase
%   Result:         cellarray with name and content of the main phase.
    properties
        zNames;
        Operators = {'w'};
        Phase = [];
        BaseEq=[];
    end
        
    methods 
        function obj = sk_func_get_phase_vars(eq)
            obj.BaseEq=eq;
            if ~isa(obj.BaseEq, 'sk_tc_equilibrium')
                error('Must set BaseEQ first');
            end
        end
        
        function r = get.zNames(obj)
            if isempty(obj.Phase)
                name = 'mainph';
            else
                name = obj.Phase;
            end
            
            len=length(obj.Variables_TC);
            tmp = cell(1, length(obj.components) * len);
            count = 1;
            for i=1:len
                for j=1:length(obj.components)
                    tmp{count} = sprintf('%s(%s,%s)', obj.Variables_TC{i}, name, obj.components{j});
                    count = count + 1;
                end
            end
            r = [{'Mainphase'},{'VPV'}, tmp];
        end
        
        function res = calculate(obj, vars, values )
            eq=obj.BaseEq;
            eq.StartSandbox;
            eq.SetConditionsForComponents(vars, values);
            
            if isempty(obj.Phase)
                [name, cnt] = eq.GetMainPhase;
            else
                name = obj.Phase;
                cnt = eq.GetValue('vpv(%s)', name);
            end
            elm=eq.GetElements;
            len=length(obj.Operators);
            tmp = cell(1,length(elm) * len);
            count = 1;
            for i=1:len
                for j=1:length(elm)
                    tmp{count}={eq.GetValue('%s(%s,%s)', obj.Variables_TC{i}, name, obj.components{j})};
                    count = count + 1;
                end
            end
            eq.EndSandbox;
            res = [{name}, {cnt}, tmp];
        end
    end
    
    methods (Static)
        %sk_func_get_phase_vars.get(Phase, Variables) 
        %       Queries the given set of Variables of a Phase
        %       or the active main-phase if Phase is empty [] (with greatest vol-%)
        function res = get(eq, Phase, Variables)
            slv = sk_func_get_phase_vars(eq);
            slv.Phase = Phase;
            slv.Variables_TC = Variables;
            res = slv.calculate({},[]);
        end
    end
end