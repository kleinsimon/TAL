classdef sk_tc_property_t_c < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Evaluates the ac1 temperature of
% steels. 
%
%   StartT:     Starting temperature. This temperature must be above AC1.
%               Defaults to 1100K. If no major fcc phase is found, t is
%               raised until MaxT (1250K). 
%   Result:     AC1 in K
    properties
        Temp;
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'T'};
        %Names of properties which have to be calculated first
        DependsOn={}; 
        SetBefore=0;
    end
    
    methods 
        function obj=sk_tc_property_t_c(temp)
            t = sk_tc_prop_result.getByType(temp, 1);
            if isempty(t)
                if (isnumeric(temp{1}))
                    obj.Temp=sk_tc_prop_result('Temperature', 1, temp{1}, 'C');
                else
                    error('no temperature submitted');
                end
            else
                obj.Temp = t{1};
            end
        end
        
        function res = calculate(obj, ~, ~, ~)
            if strcmpi(obj.Temp.unit, 'K')
                obj.Temp = obj.Temp.Clone;
                obj.Temp.value = obj.Temp.value - 273.15;
                obj.Temp.unit = 'C';
            elseif strcmpi(obj.Temp.unit, 'C')
                
            else 
                error('unit unknown');
            end

            res = obj.Temp;
        end
    end
end