function [ varCellOut ] = sk_tool_mkvarargout( nVarArgOut, varargin )
    varCellOut = cell(nVarArgOut,1);
    for i=1:max(nVarArgOut,1)
        varCellOut{i}=varargin{i};
    end
end

