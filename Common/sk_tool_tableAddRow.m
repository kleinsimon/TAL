function table = sk_tool_tableAddRow( table, row )
%table = sk_tableAddRow( table, row )
%   Adds the given Row to table. 
    if isempty(table.Properties.VariableNames)
        table = [table; cell2table(row)];
    else
        table = [table; cell2table(row,'VariableNames',table.Properties.VariableNames)];
    end
end

