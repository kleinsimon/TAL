classdef sk_tc_property_gammaName < sk_tc_property
% sk_tc_property_gammaName: Gets the name of the FCC matrix phase.
%

    properties
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'gammaName'};
        %Names of properties which have to be calculated first
        DependsOn={'gammaT'}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_gammaName(~)
            
        end
        function res = calculate(obj, ~, eq, deps)
            try
                t=deps{1}.value;
                eq.SetCondition('t', t);
                fccName = eq.GetMainPhase;

                me = eq.GetMainElementInPhase(fccName);
                if ~strcmpi(me, 'FE')
                    warning('No fcc iron matrix found.');
                    res = nan;
                    return;
                end

                res = sk_tc_prop_result(obj.zNames, 4, fccName);
            catch
                res = nan;
            end
        end
    end
end