function s=sk_tool_allsets(n)
%
% INPUT: n integer >=0
% OUTPUT: binary coding of all subsets of {1,...,n}

if n==0
    s=false(1,0);
else
    snminus1=sk_tool_allsets(n-1);
    c=class(snminus1);
    j=size(snminus1,1);
    s=[false(j,1,c) snminus1; ...
       true(j,1,c) snminus1];
end
