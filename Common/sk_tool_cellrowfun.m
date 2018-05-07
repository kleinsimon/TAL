function [ CO ] = sk_tool_cellrowfun( func, CI )
    rows=size(CI,1);
    CO=cell(rows,1);
    for i=1:rows
        r=cellflat(CI(i,:));
        CO{i}=func(r);
    end
end

