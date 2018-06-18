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
        DependsOn={'alphaName','gammaT'}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_ac3(~)
            
        end
        function res = calculate(obj, ~, eq, deps)
            sN = deps{1}.value;
            sT = deps{2}.value;
            
            try 
                eq.SetCondition('t',500);
                eq.Calculate;
                
                eq.DeleteCondition('T');               
                eq.SetPhaseStatus(sN,'fixed',1e-6);
                
                eq.Calculate;
                eq.Calculate;
                
                res = sk_tc_prop_result(obj.zNames, 1, eq.GetValue('T'), 'K');
            catch e
                warning(e.message);
                res = nan;
            end
        end
    end
end