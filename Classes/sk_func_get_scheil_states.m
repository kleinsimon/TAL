classdef sk_func_get_scheil_states < sk_funcs
% sk_func_get_scheil_states:     Child of sk_funcs. Gets the sk_tc_states of the
% liquid at begin and end of solidification
%
%   Result:     Segregation Factor
    properties 
        StartT=[];
        BaseEq=[];
        zNames = {'LiqState','SolState'};
    end
    
    properties (Access=private)
        Scheil;
    end
    
    methods 
        function obj = sk_func_get_scheil_states(eq)
            obj.BaseEq=eq;
            if ~isa(obj.BaseEq, 'sk_tc_equilibrium')
                error('Must set BaseEQ first');
            end
            obj.Scheil=sk_tc_scheil(eq);
            obj.Scheil.Silent=1;           
        end
        function [liq,sol] = calculate(obj, vars, values )
           
            obj.Scheil.StartT=obj.StartT;
            eq=obj.BaseEq.Clone;

            eq.SetConditionsForComponents(vars, values);            
            obj.Scheil.calculate;

            [liq,sol] = obj.Scheil.getStates;
        end
    end
    
    methods (Static)
        %sk_func_calc_segrfact.get() returns the Segregration Facor for
        %Elements
        function res = get(eq, elm)
            slv = sk_func_get_scheil_states(eq);
            slv.Elements=elm;
            res = slv.calculate({},[]);
        end
    end
end

