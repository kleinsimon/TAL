function [ CO ] = sk_tool_plotfunctionlog( L )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    rows = size(L, 1);
    CO=cell(rows,1);
    
    for i=1:rows
        %r = [{L{i,1}} L{i,1:end}];
        r=sk_tool_trimcell(L(i,2:end));
        r = cellfun(@parsearg, r, 'UniformOutput', false);
        args=strjoin(r(:), ', ');
        CO{i}=sprintf('%s(%s)', L{i,1}, args);
    end
end

function o = parsearg(c) 
    if iscell(c)
        o=[ '{' strjoin(cellfun(@parsearg, c, 'UniformOutput',false)) '}'];
        return;
    end
    if ismatrix(c)
        o=mat2str(c);
        return;
    end
    
    o=c;
end