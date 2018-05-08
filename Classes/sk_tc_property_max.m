classdef sk_tc_property_max < sk_tc_property
% sk_tc_property_max: Child of sk_funcs. Maximizes the function given in
% the first parameter by variating the conditions given in the other
% parameters
%
    properties

    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'MAX'};
        SetBefore=1;
        DependsOn={}; 
        Function;
        Parameters;
    end
    
    properties (Access=private)
        
    end
    
    methods 
        function obj = sk_tc_property_max(pipe)
            obj.Function = pipe{1};
            obj.Parameters = pipe(2:end);
        end
        
        function res = calculate(obj, ~, eq, ~)
            np = numel(obj.Parameters);
            
            f = sk_func_tc_properties(eq, obj.Function);
            
            parms = sk_solverParams(np);
            parms.x0 = cell2mat(eq.GetValue(obj.Parameters));
            %parms.A = [ 1  ]; 
            %parms.b = 0.5;
            %parms.ub = [0.03 ]; 
            %parms.lb = [0];
            
            solver = sk_solver_minimize_value;
            solver.invert = true;
            solver.varComponents=obj.Parameters;
            solver.minFunc = f;
            solver.solvParm = parms;
            
            r = solver.calculate;
            cond = {obj.Parameters' r{1}'};
            
            res = sk_tc_prop_result(obj.zNames, 2, cond);
        end
    end
end