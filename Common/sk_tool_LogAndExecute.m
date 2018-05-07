function varargout = sk_tool_LogAndExecute(func, varargin)
    n=length(varargin);
    test(end+1,1:n+1) = [{func2str(func)} varargin];
    if  nargout>0
        varargout{1:nargout} = func(varargin{:});
    else
        func(varargin{:});
    end
end