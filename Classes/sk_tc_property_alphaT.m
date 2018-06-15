classdef sk_tc_property_alphaT < sk_tc_property
% sk_func_calc_ac1: Child of sk_funcs. Searches a temperature, where the
% matrix is ferritic.
%
%   StartT:     Starting temperature. This temperature must be above AC1.
%               Defaults to 1100K. If no major bcc phase is found, t is
%               lowered until MinT (500K). 

    properties
        StartT = 1100;  %Starting Temperature to find a 
        BigStepT = 200;
        StepT = 50;
        MinT=500;
        MaxT=1250;
        Tol = 1e-8;
        Verbose=1;
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'alphaT','alphaName'};
        %Names of properties which have to be calculated first
        DependsOn={'gammaT', 'gammaName'}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_alphaT(~)
            
        end
        function res = calculate(obj, ~, eq, deps)
           
            t=deps{1}.value;
            fccName=deps{2}.value;
            try
                %Search BCC
                while 1
                    t = t - obj.BigStepT;

                    if t < obj.MinT
                        error('FCC-->BCC transition could not be found');

                        break;
                    end

                    eq.SetCondition('T', t);

                    fcc = eq.GetValue('np(%s)', fccName);

                    if fcc<obj.Tol
                        break;      %T > AC3
                    end
                end

                res = sk_tc_prop_result(obj.zNames, 1, t, 'K');
            catch
                res = nan;
            end
        end
    end
end