function [ var ] = sk_tool_parse_varargout( n, def, varargin )
%[var] = sk_tool_parse_varargin(nargout, var1, var2, ...)
    if n==0
        var = varargin(def);
    else
        var = varargin(1:n);
    end
end

