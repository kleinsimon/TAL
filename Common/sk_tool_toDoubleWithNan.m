function [ O ] = sk_tool_toDoubleWithNan( M, nanval )
    vals = unique(M);
    nvals = M == nanval;
    vals(vals==nanval)=[];
    
    if numel(vals)~=2
        error('Contains more than 2 distinct values');
    end
    
    O = double(M == vals(1));
    O(nvals)=NaN;
end

