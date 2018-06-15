classdef sk_tc_property_ac1 < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Evaluates the ac1 temperature of
% steels (The temperature, where austenite begins to form). Not 100%
% stable. Variate Content and StartT!
%
%   Result:     AC1 in K
    properties
        Content = 1e-12; %Amount of austenite to exist. Default: 1e-12
        StartT = 600;    %Temperature to calculate first. 
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
                eq.SetCondition('t',fccT);
                eq.Calculate;
                eq.SetCondition('t',obj.StartT);
                eq.Calculate;

                eq.DeleteCondition('T');
                eq.SetPhaseStatus(fccName,'fixed',obj.Content);
                ac1 = eq.GetValue('T');

                res = sk_tc_prop_result(obj.zNames, 1, ac1, 'K');
                
            catch
                res = nan;
            end
        end
    end
end