function [ cell ] = sk_tool_addtocellunique( cell, row )
% sk_tool_addtocellunique( cell, row )
% Adds row to cell, overwriting a row with the same first cell of row.
% If no identifier is found, the row is appended. Case Sensitive

    id = row(1,1);
    fi = find(ismember(cell(:,1),id));
    if isempty(fi)
        cell=[cell; row];
    else
        cell(fi,:)=row;
    end
end

