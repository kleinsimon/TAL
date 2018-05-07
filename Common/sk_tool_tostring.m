function [ s ] = sk_tool_tostring( v )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    if isnumeric(v)
        s=num2str(v);
        return;
    end
    if iscell(v)
        s=sk_tool_casttostring(v);
        return;
    end
    if isstr(v)
        s=v;
    end
end

