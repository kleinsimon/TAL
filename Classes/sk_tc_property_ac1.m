classdef sk_tc_property_ac1 < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Evaluates the ac1 temperature of
% steels. 
%
%   StartT:     Starting temperature. This temperature must be above AC1.
%               Defaults to 1100K. If no major fcc phase is found, t is
%               raised until MaxT (1250K). 
%   Result:     AC1 in K
    properties
        Tol = 1e-8;
        Verbose=1;
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'AC1'};
        %Names of properties which have to be calculated first
        DependsOn={'gammaName','gammaT'}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_ac1(~)
            
        end
        function res = calculate(obj, ~, eq, deps)
            fccName=deps{1}.value;
            fccT=deps{2}.value;
            try
                eq.Flush;
                
                eq.SetMin(0);                
                eq.KeepState=1;
                eq.SetCondition('t',fccT);
                eq.Calculate;
                eq.SetCondition('t',600);
                eq.Calculate;

                eq.DeleteCondition('T');
                eq.SetPhaseStatus(fccName,'fixed',1e-12);
                ac1 = eq.GetValue('T');

                res = sk_tc_prop_result(obj.zNames, 1, ac1, 'K');
                
            catch
                res = nan;
            end
        end
    end
end