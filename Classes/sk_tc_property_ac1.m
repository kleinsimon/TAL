classdef sk_tc_property_ac1 < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Evaluates the ac1 and ac1,3 temperature of
% steels (austenite begins to form).
%
%   Result:     AC1 in K
    properties
        Tolerance = 1e-8;
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'AC1'};
        %Names of properties which have to be calculated first
        DependsOn={'gammaName', 'alphaT'}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_ac1(~)
            
        end
        function res = calculate(obj, ~, eq, deps)
            sN=deps{1}.value;
            sT=deps{2}.value;

            try
                cf = sk_conditionFinder;
                cf.xmin=sT;
                cf.xmax=1300+273;
                cf.tolerance=0.5;
                cf.orderRange=3;
                cf.directionDown=false;
                
                f = @(xx)(obj.CntCheck(xx, eq, sN, obj.Tolerance));

                cf.func=f;
                x=cf.calculate();
                res = sk_tc_prop_result(obj.zNames, 1, x, 'K');
                
            catch e
                warning(e.message);
                res = nan;
            end
        end
        function r=CntCheck(~, t, eq, p, tol)

            eq.SetCondition('T', t);

            vpv = eq.GetValue('vpv(%s)', p);

            r = abs(vpv)>=tol;
        end
    end
end