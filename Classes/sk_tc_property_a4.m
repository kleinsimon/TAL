classdef sk_tc_property_a4 < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Evaluates the ac1 temperature of
% steels. 
%
%   StartT:     Starting temperature. This temperature must be above AC1.
%               Defaults to 1100K. If no major fcc phase is found, t is
%               raised until MaxT (1250K). 
%   Result:     AC1 in K
    properties
        Verbose=0;
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
            n=deps{2}.value;               
            t=deps{1}.value;
            
            eq.Flush;
            eq.SetCondition('t', t-100);
            eq.Calculate;
                
            eq.DeleteCondition('T');
            eq.SetPhaseStatus(n,'fixed',0);
            a4 = eq.GetValue('T');

            res = sk_tc_prop_result(obj.zNames, 1, a4, 'K');
        end
    end
end