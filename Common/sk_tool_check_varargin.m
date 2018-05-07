function sk_tool_check_varargin( varin, varargin )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    
    if length(varin)~=length(varargin)
        error('varargin could not be verified, length mismatch');
    end
    for i=1:length(varin)
        v = varin{i};
        checkfun = varargin{i};
        if ~checkfun(v)
            error ('Input parameter error');
        end
    end
end

