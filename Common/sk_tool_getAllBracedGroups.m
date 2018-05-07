function [ tokens ] = sk_tool_getAllBracedGroups( string )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    s = length(string);

    [mstart, mend] = regexp(string, '([a-zA-Z]+[a-zA-Z0-9_]*\()');

    counts = numel(mstart);
    tokens=cell(1,counts);
    
    for i=1:counts
        n = mend(i);
        
        diff=1;
        pos=n;
        while diff~=0
            pos=pos+1;
            c=string(pos);

            if c == '('
                diff = diff+1;
            end
            
            if c == ')'
                diff = diff-1;
            end
            
            if pos > s
                error('Missing ) in Formula');
            end
        end
        tokens{i}=string(mstart(i):pos);
    end   
end

