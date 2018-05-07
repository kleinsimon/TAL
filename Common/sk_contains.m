function res = sk_contains (haystack, needle)
    if iscell(haystack)
        h=haystack;
    else
        h={haystack};
    end
    
    r=zeros(size(h));
    
    for i=1:numel(h)
        p=sk_tool_strifind(h{i}, needle);
        r(i)=~isempty(p);
    end
    
    res = r;
end