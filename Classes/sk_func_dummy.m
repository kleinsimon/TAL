classdef sk_func_dummy < sk_funcs
% sk_func_dummy: Child of sk_funcs. Dummy function. Gives back input
% parameters
%
%   Result:     String of input parameters
    properties
        zNames={'DUMMY'};
        BaseEq=[];
    end
    
    methods 
        function res = calculate(~, vars, values )
            res = [];
            for i=1:length(vars)
                res = [res, sprintf('%s=%f',vars{i},values(i))];
            end
        end
    end
    
    methods (Static)
        %sk_func_dummy.get() returns absolutely nothing
        function res = get()
            slv = sk_func_dummy;
            res = slv.calculate({},[]);
        end
    end
end



