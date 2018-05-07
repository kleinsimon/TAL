function cell = sk_tool_mkcell(v)
    if iscell(v)
        cell=v;
    else
        cell={v};
    end
end