function [ row ] = sk_tool_getcellrowbyid( cell, id )
% sk_tool_getcellrowbyid( cell, row )
% Returns the row beginning with the cell id from cellarray cell

    fi = find(ismember(cell(:,1),id));
    row=cell(fi,:);
end

