classdef sk_tc_property_gammaT < sk_tc_property
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
        zNames={'gammaT'};
        %Names of properties which have to be calculated first
        DependsOn; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_gammaT(~)
            
        end
        function res = calculate(obj, ~, eq, ~)
           
            t=obj.StartT;
            while 1 
                eq.SetCondition('T', t);

                fccName = eq.GetMainPhase;

                if sk_tool_strifind(fccName, 'fcc')==1
                    break;
                end
                t = t + obj.StepT;

                if t > obj.MaxT
                    res = {};
                    warning('FCC Field could not be found');
                    eq.EndSandbox;
                    return;
                end
            end
            res = sk_tc_prop_result(obj.zNames, 1, t, 'K');
        end
    end
end