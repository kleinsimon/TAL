function sk_tool_xprintf(format, x, l)
    if iscell(x)
        for i=1:numel(x)
            sk_tool_xprintf(format, x{i}, l);
        end
    else
        fprintf('%-*s', l, sprintf(format,x));
    end
end