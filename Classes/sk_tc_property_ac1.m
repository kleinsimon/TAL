classdef sk_tc_property_ac1 < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Evaluates the ac1 temperature of
% steels. Instable, if Delta-Ferrite exsists
%
%   Result:     AC1 in K
    properties
        Tol = 1e-8;
        Verbose=1;
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'AC1'};
        %Names of properties which have to be calculated first
        DependsOn={'gammaName'}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_ac1(~)
            
        end
        function res = calculate(obj, ~, eq, deps)
            fccName=deps{1}.value;

            try
%                 eq.Flush;
%                 
%                 eq.SetMin(0);                
%                 eq.KeepState=1;
%                 eq.SetCondition('t',fccT);
%                 eq.Calculate;
%                 eq.SetCondition('t',600);
%                 eq.Calculate;
% 
%                 eq.DeleteCondition('T');
%                 eq.SetPhaseStatus(fccName,'fixed',1e-12);
%                 ac1 = eq.GetValue('T');

                problem=struct;
                problem.x0=800+273.15;
                problem.lb=600+273.15;
                problem.ub=1100+273.15;
                problem.solver='fminsearch';
                problem.objective = @(t)(obj.CntOrT(t, eq, fccName, 1e-6));
                problem.options = optimset;
                problem.options.Display="none";
                problem.options.TolX = 0.5;
                problem.options.TolFun = 0.1;

                x = fminsearch(problem);

                res = sk_tc_prop_result(obj.zNames, 1, x, 'K');
                
            catch
                res = nan;
            end
        end
        function r=CntOrT(~, t, eq, p, tol)

            eq.SetCondition('T', t);

            vpv = eq.GetValue('vpv(%s)', p);

            if abs(vpv)<=tol
                r=1/t;
            else
                r=vpv;
            end
        end
    end
end