classdef sk_func_get_phase_amounts < sk_funcs
%sk_func_get_phase_amounts: Child of sk_funcs, class for getting the phase
%amounts on a given point
%Result:    cellarray with content of each phase.
    properties
        zNames;
        tc_variable = 'vpv';
        BaseEq=[];
    end
    
    properties (Access=private)
        phases;
    end
    
    methods 
        function obj = sk_func_get_phase_amounts(eq, varargin)
            obj.BaseEq=eq;
            if ~isa(obj.BaseEq, 'sk_tc_equilibrium')
                error('Must set BaseEQ first');
            end
            [obj.phases] = sk_tool_parse_varargin(varargin, obj.BaseEq.GetPhases);
        end
        
        function r = get.zNames(obj)
            r = cellfun(@(c)(sprintf('%s(%s)', obj.tc_variable, c)), obj.phases, 'UniformOutput', false);
        end
        
        function res = calculate(obj, vars, values )
            eq=obj.BaseEq.Clone;
            eq.SetConditionsForComponents(vars, values);
            
            cnt = cellfun(@(c)(eq.GetValue('%s(%s)', obj.tc_variable, c)), obj.phases, 'UniformOutput', false);

            res = cnt;
        end
    end
    
    methods (Static)
        %sk_func_get_phase_contents.get() Returns the amount of each phase
        function res = get(eq)
            slv = sk_func_get_phase_amounts(eq);
            res = slv.calculate({},[]);
        end
    end
end