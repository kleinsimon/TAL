classdef sk_tc_property_tsol < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Evaluates the ac1 temperature of
% steels. 
%
%   StartT:     Starting temperature. This temperature must be above AC1.
%               Defaults to 1100K. If no major fcc phase is found, t is
%               raised until MaxT (1250K). 
%   Result:     AC1 in K
    properties
        Amount = 1e-6;
        MinT = 900+273.15;
        MaxT = 2000+273.15;
        Verbose=1;
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'Tsol'};
        %Names of properties which have to be calculated first
        DependsOn={'liquidName'}; 
        SetBefore=1;
        ScheilObj;
    end
    
    methods 
        function obj = sk_tc_property_tsol(~)
            
        end
        function res = calculate(obj, ~, eq, deps)
            if iscell(obj.ScheilObj)
                s=obj.ScheilObj{1}.value{1};
                
                iv = s.getSolidificationInterval;
                tsol = iv.TSol;
            else
                sN=deps{1}.value;
                problem=struct;
                problem.x0=(obj.MinT+obj.MaxT)/2;
                problem.lb=obj.MinT;
                problem.ub=obj.MaxT;
                problem.solver='fminsearch';
                problem.objective = @(t)(obj.CntOrT(t, eq, sN, obj.Amount));
                problem.options = optimset;
                problem.options.Display="none";
                problem.options.TolX = 0.5;
                problem.options.TolFun = 0.1;

                tsol = round(fminsearch(problem),1);
            end
            res = sk_tc_prop_result(obj.zNames, 1, tsol, 'K');
        end
        
        function r=CntOrT(~, t, eq, p, tol)

            eq.SetCondition('T', t);

            vpv = eq.GetValue('vpv(%s)', p);

            if abs(vpv)<=tol
                r=100/t;
            else
                r=vpv*100;
            end
        end
    end
end