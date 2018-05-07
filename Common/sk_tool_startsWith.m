function res = sk_tool_startsWith(haystack, needle)
    if iscell(needle)
        n=needle;
    else
        n={needle};
    end
    
    r=NaN(size(n));
    
    %r=sk_tool_strifind(haystack, n);
    for i=1:numel(n)
        p=sk_tool_strifind(haystack, n{i});
        if isscalar(p)
            r(i)=p;
        end
    end
    res = r==1;
end