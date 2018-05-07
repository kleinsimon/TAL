function [ S ] = sk_tool_casttostring( C )
%Converts every cell of a Cellarray to string, regardless of type

    if iscell(C)
        S=cellfun(@tostring, C, 'UniformOutput', 0);        
    else
        S=sk_tool_tostring(C);
    end
end

