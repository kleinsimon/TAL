classdef sk_tc_property_tsol < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Evaluates the ac1 temperature of
% steels. 
%
%   StartT:     Starting temperature. This temperature must be above AC1.
%               Defaults to 1100K. If no major fcc phase is found, t is
%               raised until MaxT (1250K). 
%   Result:     AC1 in K
    properties
        Tolerance = 1e-6;
        MinT = 900+273.15;
        MaxT = 1550+273.15;
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
                cf = sk_conditionFinder;
                cf.Xmin=obj.MinT;
                cf.Xmax=obj.MaxT;
                cf.Tolerance=0.5;
                cf.OrderRange=3;
                cf.OrderStep=0.75;
                cf.Verbose=0;
                cf.DirectionDown=true;
              
                f = @(xx)(obj.CntCheck(xx, eq, sN, obj.Tolerance));

                cf.Func=f;
                tsol=cf.calculate();
            end
            res = sk_tc_prop_result(obj.zNames, 1, tsol, 'K');
        end
        
        function r=CntCheck(~, t, eq, p, tol)

            eq.SetCondition('T', t);

            vpv = eq.GetValue('vpv(%s)', p);

            r=vpv<=tol;
        end
    end
end