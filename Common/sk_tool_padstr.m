function [ s ] = sk_tool_padstr( str, len, varargin )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    left = sk_tool_parse_varargin(varargin, 0);
    pad = len-length(str);
    
    if len<=0
        s=str;
        return;
    end

    p = repmat(' ', 1, pad);
    
    if left
        s = [p str];
    else
        s = [str p];
    end
end

