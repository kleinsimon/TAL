classdef sk_tc_property_alphaName < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Evaluates the ac1 temperature of
% steels. 
%
%   StartT:     Starting temperature. This temperature must be above AC1.
%               Defaults to 1100K. If no major fcc phase is found, t is
%               raised until MaxT (1250K). 
%   Result:     AC1 in K
    properties
        Verbose=1;
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'alphaName'};
        %Names of properties which have to be calculated first
        DependsOn={}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_alphaName(~)
            
        end
        function res = calculate(obj, ~, eq, ~)
           
            %t = deps{1}.value;
            t=500;
            eq.SetCondition('t',t-1);
            eq.Calculate;
            try
                bccName = eq.GetMainPhase('np', {'bcc'}');
            
                res = sk_tc_prop_result(obj.zNames, 4, bccName);
            catch
                res = nan;
            end
        end
    end
end