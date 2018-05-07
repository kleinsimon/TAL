classdef sk_tc_property_sfe < sk_tc_property
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
        zNames={'SFE'};
        %Names of properties which have to be calculated first
        DependsOn={'mainphase'}; 
        SetBefore=1;
    end

    methods 
        function obj = sk_tc_property_sfe(~)
        end
        
        function res = calculate(obj, ~, eq, deps)

            mainph = deps{1}.value;
            
            if sk_tool_strifind(mainph, 'fcc')~=1
                error('Main Phase for SFE must be FCC')
            end
            
            eq.ApplyLocalComposition(mainph);

            eq.SetPhaseStatus('*','SUSPENDED',0);
            eq.SetPhaseStatus('fcc','ENTERED',0.9999999);                  %Set FCC as the only stable phase
            eq.Calculate;

            geFcc = eq.GetValue('gm(fcc)');                                %Calculate Gibbs Energy of FCC
            vmFcc = eq.GetValue('vm(fcc)');                                %Calculate molar volume of FCC

            eq.SetPhaseStatus('*','SUSPENDED',0);
            eq.SetPhaseStatus('hcp','ENTERED',0.9999999);                  %Set HCP as the only stable Phase
            eq.Calculate;

            geHcp = eq.GetValue('gm(hcp)');                                %Calculate Gibbs Energy of FCC

            deltaG = (geHcp-geFcc) * 1000;
            vm = vmFcc^(-2/3);
            n0 = (6.02214E23)^(-1/3);
            mult = 2*deltaG*vm*n0;
            sfe = mult + 44.12;

            res = sk_tc_prop_result(obj.zNames, 6, sfe);
        end
    end
end