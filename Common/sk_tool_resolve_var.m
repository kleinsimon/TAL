function [ ret ] = sk_tool_resolve_var( var )
%sk_tool_resolve_var(var) Resolves a function handle to its value. If value is
%given, it returns the value.
    if (isa(var,'function_handle'))
        ret = feval(var);
    else
        ret = var;
    end
end

