classdef sk_tc_property_a4 < sk_tc_property
% sk_tc_property_a4: Child of sk_funcs. Evaluates the a4 temperature of
% steels (Austenite->Delta Ferrite). NOT STABLE!

    properties
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'a4'};
        %Names of properties which have to be calculated first
        DependsOn={'deltaT','deltaName'}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_a4(~)
            
        end
        function res = calculate(obj, ~, eq, deps)
            n=deps{2}.value;               
            t=deps{1}.value;
            
            eq.Flush;
            eq.SetCondition('t', t-100);
            eq.Calculate;
                
            eq.DeleteCondition('T');
            eq.SetPhaseStatus(n,'fixed',0);
            a4 = eq.GetValue('T');

            res = sk_tc_prop_result(obj.zNames, 1, a4, 'K');
        end
    end
end