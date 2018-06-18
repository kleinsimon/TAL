classdef sk_func_get_values < sk_funcs
% sk_func_get_value:    Child of sk_funcs. Queries a TC-Value.
%
%   tc_expression:  Cellarray of Expressions to evaluate. eg. w(fcc, c) etc..
%   Result:         Result of expression as given by TC
    properties
        zNames;
        Queries;
        BaseEq=[];
    end
    
    methods 
        function obj=sk_func_get_values(eq)
            obj.BaseEq=eq;
            if ~isa(obj.BaseEq, 'sk_tc_equilibrium')
                error('Must set BaseEQ first');
            end
        end
        function r = get.zNames(obj)
            if isempty(obj.Queries)
                error ('no expression set. Set Queries to e.g. {"w(c,fcc)"}');
            end
            r = sk_tool_mkcell(obj.Queries);
        end
        
        function res = calculate(obj, vars, values )
            if isempty(obj.Queries)
                error ('no expression set. Set Queries to e.g. "w(c,fcc)"');
            end
            eq = obj.BaseEq.Clone;
            eq.SetConditionsForComponents(vars, values);

            res = cellfun(@(exp)(eq.GetValue(exp)), obj.Queries);
        end
    end
    
    methods (Static)
        %sk_func_get_value.get(expression) Queries the given TC-Expression and returns the
        %result
        function res = get(eq,tc_expression)
            slv = sk_func_get_value(eq);
            slv.tc_expressions = sk_tool_mkcell(tc_expression);
            res = slv.calculate({},[]);
        end
    end
end