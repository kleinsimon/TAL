classdef sk_tc_property_alphaName < sk_tc_property
% sk_tc_property_alphaName: Child of sk_funcs. Returns the phase name of the
% ferritic matrix. 
%
    properties
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