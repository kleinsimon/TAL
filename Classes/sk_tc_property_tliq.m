classdef sk_tc_property_tliq < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Evaluates the ac1 temperature of
% steels. 
%
%   StartT:     Starting temperature. This temperature must be above AC1.
%               Defaults to 1100K. If no major fcc phase is found, t is
%               raised until MaxT (1250K). 
%   Result:     AC1 in K
    properties
        Amount = 1;
        LiquidName = 'Liq';
        Verbose=1;
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'Tliq'};
        %Names of properties which have to be calculated first
        DependsOn={}; 
        SetBefore=1;
        ScheilObj;
    end
    
    methods 
        function obj = sk_tc_property_tliq(varargin)
            obj.ScheilObj = sk_tc_prop_result.getByType(varargin, 10);
        end
        function res = calculate(obj, ~, eq, deps)
            if ~isempty(obj.ScheilObj)
                s=obj.ScheilObj{1}.value{1};
                
                iv = s.getSolidificationInterval;
                tliq = iv.TLiq;
            else
                %tsol = deps{1}.value;
                n=eq.GetValue('n');
                %t = deps{1}.value;
                %eq.TCSYS.Flush;
                eq.SetCondition('t', 300);
                eq.Calculate;
                %eq.TCSYS.Flush;
                eq.DeleteCondition('T');
                eq.SetPhaseStatus(obj.LiquidName,'fixed',n*obj.Amount);
                eq.Calculate;
                tliq = eq.GetValue('T');
            end
            res = sk_tc_prop_result(obj.zNames, 1, tliq, 'K');
        end
    end
end