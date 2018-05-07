classdef sk_tc_property_tcvalue < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Evaluates the ac1 temperature of
% steels. 
%
%   StartT:     Starting temperature. This temperature must be above AC1.
%               Defaults to 1100K. If no major fcc phase is found, t is
%               raised until MaxT (1250K). 
%   Result:     AC1 in K
    properties
        Query;
        Amount = 1e-6;
        LiquidName = 'Liq';
        Verbose=1;
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'TC'};
        %Names of properties which have to be calculated first
        DependsOn={}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_tcvalue(varargin)
            obj.Query = varargin{1};
        end
        function n = get.zNames(obj)
            n={['TC_' obj.Query{:}]};
        end
        function res = calculate(obj, ~,  eq, ~)
            query = sprintf('%s(%s)', obj.Query{1}, strjoin(obj.Query(2:end),','));
            
            r = eq.GetValue(query);
            res = sk_tc_prop_result(obj.zNames, 6, r);
        end
    end
end