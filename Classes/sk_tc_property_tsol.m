classdef sk_tc_property_tsol < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Evaluates the ac1 temperature of
% steels. 
%
%   StartT:     Starting temperature. This temperature must be above AC1.
%               Defaults to 1100K. If no major fcc phase is found, t is
%               raised until MaxT (1250K). 
%   Result:     AC1 in K
    properties
        Amount = 1e-12;
        LiquidName = 'LIQUID';
        Verbose=1;
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'Tsol'};
        %Names of properties which have to be calculated first
        DependsOn={}; 
        SetBefore=1;
        ScheilObj;
    end
    
    methods 
        function obj = sk_tc_property_tsol(~)
            
        end
        function res = calculate(obj, ~, eq, ~)
            if iscell(obj.ScheilObj)
                s=obj.ScheilObj{1}.value{1};
                
                iv = s.getSolidificationInterval;
                tsol = iv.TSol;
            else
                %n=eq.GetValue('n');
                %t=deps{1}.value;
                
                %eq.TCSYS.Flush;
                eq.SetCondition('t', 500);
                eq.Calculate;
                
                eq.DeleteCondition('T');
                eq.SetPhaseStatus(obj.LiquidName,'fixed',obj.Amount);
                eq.Calculate;
                tsol = eq.GetValue('T');
            end
            res = sk_tc_prop_result(obj.zNames, 1, tsol, 'K');
        end
    end
end