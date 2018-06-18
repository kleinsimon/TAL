classdef sk_tc_property_a4 < sk_tc_property
% sk_tc_property_a4: Child of sk_funcs. Evaluates the a4 temperature of
% steels (Austenite->Delta Ferrite). NOT STABLE!

    properties
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'a4'};
        %Names of properties which have to be calculated first
        DependsOn={'deltaT','deltaName'}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_a4(~)
            
        end
        
        function res = calculate(obj, ~, eq, deps)
            deltaT=deps{1}.value;
            deltaName=deps{2}.value;

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
                problem.x0=deltaT-99;
                problem.lb=deltaT-100;
                problem.ub=deltaT;
                problem.solver='fminsearch';
                problem.objective = @(t)(obj.CntOrT(t, eq, deltaName, 1e-6));
                problem.options = optimset;
                problem.options.Display="iter-detailed";
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