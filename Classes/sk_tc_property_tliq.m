classdef sk_tc_property_tliq < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Evaluates the ac1 temperature of
% steels. 
%
%   StartT:     Starting temperature. This temperature must be above AC1.
%               Defaults to 1100K. If no major fcc phase is found, t is
%               raised until MaxT (1250K). 
%   Result:     AC1 in K
    properties
        Tolerance = 1e-6;
        MinT = 500+273.15;
        MaxT = 1600+273.15;
        Verbose=1;
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'Tliq'};
        %Names of properties which have to be calculated first
        DependsOn={'liquidName'}; 
        SetBefore=1;
        ScheilObj;
    end
    
    methods 
        function obj = sk_tc_property_tliq(varargin)
            obj.ScheilObj = sk_tc_prop_result.getByType(varargin, 10);
        end
        function res = calculate(obj, ~, eq, deps)
            sN = deps{1}.value;
            if ~isempty(obj.ScheilObj)
                s=obj.ScheilObj{1}.value{1};
                
                iv = s.getSolidificationInterval;
                tliq = iv.TLiq;
            else
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
                tliq=cf.calculate();
            end
            res = sk_tc_prop_result(obj.zNames, 1, tliq, 'K');
        end
        
        function r=CntCheck(~, t, eq, p, tol)
            %fprintf('%g\n', t);
            eq.SetCondition('T', t);
            vpv = eq.GetValue('vpv(%s)', p);
            r=abs(vpv)<1-tol;
        end
    end
end