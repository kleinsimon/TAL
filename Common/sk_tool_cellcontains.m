function [ r ] = sk_tool_cellcontains( C, o )
    s = size(C);
    r = false(numel(C));
        
    for i=1:numel(C)
        r(i)= C{i}==o;
    end
    
    r = ind2sub(s,r);
end

