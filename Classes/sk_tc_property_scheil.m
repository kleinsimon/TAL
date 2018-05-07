classdef sk_tc_property_scheil < sk_tc_property
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
    properties (Access=private)
        Scheil;
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'Scheil'};
        %Names of properties which have to be calculated first
        DependsOn={'tliq'}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_scheil(~)
            
        end
        function res = calculate(obj, ~, eq, cond)
            scheil=sk_tc_scheil(eq);
            scheil.Silent=2;     
            scheil.StartT = cond{1}.value+2;
            
            scheil.calculate;
            
            res = sk_tc_prop_result(obj.zNames, 10, {scheil});
        end
    end
end