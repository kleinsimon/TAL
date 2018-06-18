classdef sk_tc_property_ac3 < sk_tc_property
% sk_tc_property_ac3: Child of sk_funcs. Evaluates the ac3 temperature of
% steels (All Ferrite is transformed to Austenite). 
%
%   Result:     AC3 in K
    properties

    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'AC3'};
        %Names of properties which have to be calculated first
        DependsOn={'alphaName'}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_ac3(~)
            
        end
        function res = calculate(obj, ~, eq, deps)
            sN = deps{1}.value;
           
            try 
%                 eq.SetCondition('t',500);
%                 eq.Calculate;
%                 
%                 eq.DeleteCondition('T');               
%                 eq.SetPhaseStatus(sN,'fixed',1e-6);
%                 
%                 eq.Calculate;
%                 eq.Calculate;
                
                problem=struct;
                problem.x0=800+273.15;
                problem.lb=600+273.15;
                problem.ub=1100+273.15;
                problem.solver='fminsearch';
                problem.objective = @(t)(obj.CntOrT(t, eq, sN, 1e-6));
                problem.options = optimset;
                problem.options.Display="none";
                problem.options.TolX = 0.5;
                problem.options.TolFun = 0.1;

                x = fminsearch(problem);


                res = sk_tc_prop_result(obj.zNames, 1, x, 'K');
            catch e
                warning(e.message);
                res = nan;
            end
        end
        
        function r=CntOrT(~, t, eq, p, tol)

            eq.SetCondition('T', t);

            vpv = eq.GetValue('vpv(%s)', p);

            if abs(vpv)<=tol
                r=t;
            else
                r=vpv*100;
            end
        end
    end
end