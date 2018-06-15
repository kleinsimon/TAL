classdef sk_tc_property_ms_rowland < sk_tc_property
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
        zNames={'MS_Rownland'};
        %Names of properties which have to be calculated first
        DependsOn={'mainphase'}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_ms_rowland(~)
            
        end
        function res = calculate(obj, ~, eq, deps)
  
            ph = deps{1}.value;

            EM = eq.GetValue('w(%s,*)',ph);
            EM(:,1) = eq.GetElements;

            wpc=@(elm)(100*sk_tool_def(0,EM{strcmpi(EM(:,1),elm),2}));

            ms = 772 -333*wpc('C') -11*wpc('SI') -33*wpc('MN') -17*wpc('NI') -28*wpc('CR') -11*wpc('MO') -11*wpc('W') +10*wpc('CO');

            res = sk_tc_prop_result(obj.zNames, 1, ms, 'K');
        end
    end
end