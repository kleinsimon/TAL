classdef (Abstract) sk_targets < handle
   % Abstract class for sk_targets
    properties (Abstract)
    end
    methods (Abstract)
        res = getScalarResult(obj, comps, vec);
    end
end 
