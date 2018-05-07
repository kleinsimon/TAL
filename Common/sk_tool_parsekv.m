function [ out ] = sk_tool_parsekv( kv, varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    [vsep, ksep] = sk_tool_parse_varargin(varargin, ' ', '=');

    tmp = strsplit(kv, vsep);
    n=length(tmp);
    out = cell(n, 2);
    for i=1:n
        t = strsplit(tmp{i}, ksep);
        k=t{1};
        v=t{2};
        [num, status] = str2num(v);
        if status
            v=num;
        end
        out(i,:)={k v};
    end
end

