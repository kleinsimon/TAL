function [ cell ] = sk_tool_delcellrowbyid( cell, id )
% sk_tool_delcellrowbyid( cell, id )
% Deletes the row beginning with the cell id from Cellarray cell

    cell(strcmpi(id,cell(:,1)),:)=[];
end

