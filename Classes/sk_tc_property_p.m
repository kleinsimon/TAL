classdef sk_tc_property_p < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Evaluates the ac1 temperature of
% steels. 
%
%   StartT:     Starting temperature. This temperature must be above AC1.
%               Defaults to 1100K. If no major fcc phase is found, t is
%               raised until MaxT (1250K). 
%   Result:     AC1 in K
    properties
        Pressure;
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'P'};
        %Names of properties which have to be calculated first
        DependsOn={}; 
        SetBefore=1;
    end
    
    methods 
        function obj=sk_tc_property_p(temp)
            if isa(temp{1}, 'sk_tc_prop_result')
                obj.Pressure = temp{1};
            else
                obj.Pressure = sk_tc_prop_result('Pressure', 8, temp{1}, 'pas');
            end
        end
        function res = calculate(obj, ~, ~, ~)
            
            res = obj.Pressure;
        end
    end
end