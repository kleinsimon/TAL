classdef sk_tc_property_a4 < sk_tc_property
% sk_tc_property_a4: Child of sk_funcs. Evaluates the a4 temperature of
% steels (Austenite->Delta Ferrite). NOT STABLE!

    properties
        Tolerance = 1e-6;
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
                cf = sk_conditionFinder;
                cf.xmin=1300+273;
                cf.xmax=deltaT;
                cf.tolerance=0.5;
                cf.orderRange=2;
                cf.directionDown=true;
                
                f = @(xx)(obj.CntCheck(xx, eq, deltaName, obj.Tolerance));

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
            
            %fprintf("%g ==> %g \n", t, vpv);
            
            r = abs(vpv)<tol;
        end
    end
end