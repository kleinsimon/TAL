function [ C ] = sk_tool_csprintf( format, I, varargin )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    n=numel(I);
    C=cell(n,1);
    
    if iscell(I)
        for i=1:n
            C{i}=sprintf(format, I{i}, varargin{:});
        end
    else
        for i=1:n
            C{i}=sprintf(format, I(i), varargin{:});
        end
    end
end

