function [ newstr ] = sk_tool_replaceall( oldstr, Search, Replace )
%newstr = sk_tool_replaceall( oldstr, C )
%   Replaces occurancec of all entries in Cellarray Search in string oldstr by
%   the entries in Replace, if Replace has only one Element, all occurances
%   are replaced by that

    if ~iscell(Replace)
        Replace={Replace};
    end

    ns=numel(Search);
    nr=numel(Replace);
    
    newstr=oldstr;
    
    if ns>nr && nr~=1
        error('Replace must be either equal length as Search or only one Element');
    end
    
    for i=1:ns
        if nr==1
            newstr = strrep(newstr, Search{i}, Replace{1});
        else
            newstr = strrep(newstr, Search{i}, Replace{i});
        end
    end
end

