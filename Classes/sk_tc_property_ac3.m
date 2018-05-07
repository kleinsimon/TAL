classdef sk_tc_property_ac3 < sk_tc_property
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
        zNames={'AC3'};
        %Names of properties which have to be calculated first
        DependsOn={'gammaT','alphaName'}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_ac3(~)
            
        end
        function res = calculate(obj, ~, eq, deps)
            
            gammaT = deps{1}.value;
            bccName = deps{2}.value;
            %ac1 = deps{3}.value;
            
            try 
                eq.SetCondition('t',500);
                eq.Calculate;
                eq.DeleteCondition('T');

                eq.SetPhaseStatus(bccName,'fixed',0);

                eq.KeepState=1;
                res = sk_tc_prop_result(obj.zNames, 1, eq.GetValue('T'), 'K');
            catch
                res = nan;
            end
        end
    end
end