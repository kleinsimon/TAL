classdef sk_tc_property_md30 < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Evaluates the ac1 temperature of
% steels. 
%
%   StartT:     Starting temperature. This temperature must be above AC1.
%               Defaults to 1100K. If no major fcc phase is found, t is
%               raised until MaxT (1250K). 
%   Result:     AC1 in K
%   Model:              Model(s) to use.    1: Steven and Haynes
%                                           2: Andrews
%                                           3: Barbier
%                                           4: Rowland
    properties

    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'MD30'};
        %Names of properties which have to be calculated first
        DependsOn={'mainphase'}; 
        SetBefore=1;
    end
    
    properties (Access=private)
        Coeff={
          'C' 462
          'N' 462
          'SI' 9.2
          'MN' 8.1
          'CR' 13.7
          'NI' 9.5
          'MO' 18.5
        };
    end
    
    methods 
        function obj = sk_tc_property_md30(~)
            
        end
        function res = calculate(obj, ~, eq, deps)
            ph = deps{1}.value;
            
            EM = eq.GetValue('w(%s,*)',ph);
            
            [~,~,i1,i2] = sk_tool_cellintersect(EM(:,1), obj.Coeff(:,1));
            m1=cell2mat(EM(i1,2));
            m2=cell2mat(obj.Coeff(i2,2));
            
            md30 = 273.15 + 413 - sum(m1 .* m2);
            
            res = sk_tc_prop_result(obj.zNames, 1, md30, 'K');
        end
    end
end