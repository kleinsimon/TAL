function [ index ] = sk_tool_find_row( A, x, varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    
    if nargin==3
        col=varargin{1};
        if size(col) ~= [1,1]
            error ('columns must be scalar array');
        end
    else
        col=size(A,2);
    end
    
    if isempty(A) && isempty(x)
        error ('Array empty');
    end
    if col ~= size(x,2)
        error ('Size does not match');
    end
    
    
    index = find_row_mex(A, x, col);

end

