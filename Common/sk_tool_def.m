function [ r ] = sk_tool_def( d, varargin )
%sk_tool_def(defaultValue, input)       returns default, if input is empty

    if nargin == 0 || isempty(varargin)
        r=d;
    else
        r=varargin{:};
    end
end

