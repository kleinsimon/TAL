function [ varargout ] = sk_tool_forfun( fun, num )

    if isscalar(num)
        res = cell(num, 1);
    elseif iscell(num)
        res = cell(size(num));
        num=numel(num);
    end
    
    for i=1:num
        res{i}=fun(i);
    end
    if nargout>1
        varargout=res;
    else
        varargout{1}=res;
    end
end

