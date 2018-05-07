classdef (Abstract) sk_tc_property < handle
   % Abstract class for sk_solvers property getters
    properties (Abstract)

    end
    properties (Abstract,GetAccess=public,SetAccess=private)
        %Names of properties which have to be calculated first
        zNames;
        DependsOn; 
        SetBefore;
    end
    methods (Abstract)
        % Do the calcultion for the given parameter vector. length of
        % result must match length of zNames;
        result = calculate(Caller, Component, Values, Dependencies)
    end
end 
