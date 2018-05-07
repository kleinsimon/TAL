function sk_tool_evalstack( Cellarray )
% Evaluates a stack of strings in a cellarrray
    n = numel(Cellarray);
    for i=1:n
        eval(Cellarray{n});
    end
end

