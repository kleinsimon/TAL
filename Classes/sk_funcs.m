classdef (Abstract) sk_funcs < handle
   % Abstract class for sk_solvers property getters
    properties (Abstract)
        %Names of the output-variables for the result table (cellarray)
        zNames;
        BaseEq;
    end
    methods (Abstract)
        % Do the calcultion for the given parameter vector. length of
        % result must match length of zNames;
        result = calculate(Component, Values)
    end
    methods (Abstract,Static)
        % Static Version for direct calculation of the result
        result = get()
    end
end 
