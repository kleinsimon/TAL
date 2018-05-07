function [ C2 ] = sk_tool_sortbylength( C )
%[ C2 ] = sk_tool_sortbylength( C )
%Sorts the Cellarray of strings C by their length, ascending

    l = cellfun(@length, C);
    [~,i]=sort(l);
    C2 = C(i);
end

