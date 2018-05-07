function [ cell ] = sk_tool_cellupper( cell )
    for i=1:numel(cell)
        if ischar(cell{i})
            cell{i}=upper(cell{i});
        end
    end
end

