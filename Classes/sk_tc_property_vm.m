classdef sk_tc_property_vm < sk_tc_property
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
        PhaseName='';
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'VM'};
        %Names of properties which have to be calculated first
        DependsOn={}; 
        SetBefore=1;
    end

    methods 
        function obj = sk_tc_property_vm(pipe)
            tmp=sk_tc_prop_result.getByType(pipe, 4, {@ischar});
            obj.PhaseName=tmp{1}.value;
        end
        
        function res = calculate(obj, ~, eq, ~)
            ph = obj.PhaseName;
            eq.SetMin(0);
            eq.SetPhaseStatus('*','SUSPENDED',0);
            eq.SetPhaseStatus(ph,'ENTERED',1);                          %Set FCC as the only stable phase
            eq.Calculate;

            vm = eq.GetValue('vm(%s)', ph);                                %Calculate Gibbs Energy of FCC

            res = sk_tc_prop_result(obj.zNames, 6, vm);
        end
    end
end