function varargout = sk_tool_get_output(func,outputNo,varargin)
%sk_tool_get_output(func,outputNo,varargin)
    varargout = cell(max(outputNo),1);
    [varargout{:}] = func(varargin{:});
    varargout = varargout(outputNo);
end