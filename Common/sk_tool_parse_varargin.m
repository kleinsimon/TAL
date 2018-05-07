function [ varargout ] = sk_tool_parse_varargin( vars, varargin )
%[var1, var2, ...] = sk_tool_parse_varargin(vars, default1, default2, ...)
    nvars = length(vars);
    if (nvars>0)
        varargout(1:nvars) = vars;
        varargout(nvars+1:nargout)=varargin(nvars+1:end);
    else
        varargout = varargin;
    end
end

