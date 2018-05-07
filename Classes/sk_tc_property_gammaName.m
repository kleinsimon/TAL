classdef sk_tc_property_gammaName < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Evaluates the ac1 temperature of
% steels. 
%
%   StartT:     Starting temperature. This temperature must be above AC1.
%               Defaults to 1100K. If no major fcc phase is found, t is
%               raised until MaxT (1250K). 
%   Result:     AC1 in K
    properties
        StartT = 1100;
        BigStepT = 200;
        StepT = 50;
        MinT=500;
        MaxT=1250;
        Tol = 1e-8;
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'gammaName'};
        %Names of properties which have to be calculated first
        DependsOn={'gammaT'}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_gammaName(~)
            
        end
        function res = calculate(obj, ~, eq, deps)
            try
                t=deps{1}.value;
                eq.SetCondition('t', t);
                fccName = eq.GetMainPhase;

                me = eq.GetMainElementInPhase(fccName);
                if ~strcmpi(me, 'FE')
                    warning('No fcc iron matrix found.');
                    res = nan;
                    return;
                end

                res = sk_tc_prop_result(obj.zNames, 4, fccName);
            catch
                res = nan;
            end
        end
    end
end