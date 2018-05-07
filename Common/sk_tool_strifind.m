function [ k ] = sk_tool_strifind( str, pattern )
%Case insensitive strfind...
    k=strfind(upper(str),upper(pattern));
end

