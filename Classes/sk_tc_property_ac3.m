classdef sk_tc_property_ac3 < sk_tc_property
% sk_tc_property_ac3: Child of sk_funcs. Evaluates the ac3/acm temperature of
% steels (All Ferrite and all cementite is transformed to Austenite). 
%
%   Result:     AC3 in K
    properties
        Tolerance=1e-8;
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'AC3'};
        %Names of properties which have to be calculated first
        DependsOn={'alphaName','alphaT'}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_ac3(~)
            
        end
        function res = calculate(obj, ~, eq, deps)
            sN = deps{1}.value;
            sT = deps{2}.value;
           
            try 
                cf = sk_conditionFinder;
                cf.Xmin=sT;
                cf.Xmax=1200+273;
                cf.Tolerance=0.5;
                cf.OrderRange=3;
                cf.OrderStep=0.5;
                cf.Verbose=1;
                cf.DirectionDown=false;
                
                cem = any(strcmpi(eq.GetPhases, 'CEMENTITE'));
                
                f = @(xx)(obj.CntCheck(xx, eq, sN, obj.Tolerance, cem));

                cf.Func=f;
                x=cf.calculate();

                res = sk_tc_prop_result(obj.zNames, 1, x, 'K');
            catch e
                warning(e.message);
                res = nan;
            end
        end
        
        function r=CntCheck(~, t, eq, p, tol, cem)

            eq.SetCondition('T', t);
            vpv = eq.GetValue('vpv(%s)', p);
            if cem
                vcem = eq.GetValue('vpv(CEMENTITE)');
            else
                vcem = 0;
            end

            r = vpv+vcem<=tol;
        end
    end
end