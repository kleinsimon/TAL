classdef sk_target_getscalar < handle
   % Simply get the resulting Value of a sk_func
    properties
        zObject;
    end
    methods
        function res = getScalarResult(obj, comps, vec)
            obj.check;
            res = obj.calculate(comps, vec);
        end
        
        function check(obj)
            if ~isa(obj.zObject, 'sk_funcs')
                error ('zObject must be a sk_funcs object');
            end
        end
    end
end 
