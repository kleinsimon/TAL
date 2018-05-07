classdef (Abstract) sk_solvers < handle
   % Abstract class for tc_toolbox property getters
    properties (Abstract)
        output_names;
        %Names of the output-variables for the result table (cellarray)
        Components;
    end
    methods (Abstract)
    	result = calculate(obj, parameter_vector)
        % Do the calcultion for the given parameter vector. Result must be
        % cellarray
    end
end 
