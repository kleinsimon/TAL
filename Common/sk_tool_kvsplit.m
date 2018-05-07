function [ varargout ] = sk_tool_kvsplit( kv, varargin )
%Splits a Key-Value pair or a Array of such pairs
    [sep] = sk_tool_parse_varargin(varargin, '=');
    
    if ~iscell(kv)
        kv = strsplit(kv);
    end
    
    kv = sk_tool_mkcell(kv);
    n=numel(kv);
    out = cell(n,2);
    for i=1:n
        t = strsplit(kv{i}, sep);
        out(i,:)=t;
    end
    
    if nargout<=1
        varargout{1}=out;
    else
        if n==1
            varargout{1}=out{1,1};
            varargout{2}=out{1,2};
        else
            varargout{1}=out(:,1);
            varargout{2}=out(:,2);
        end
    end
end

