function [ out ] = sk_tool_setdiffperrow( A, B )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    mask = all(bsxfun(@ne,A,permute(B,[1 3 2])),3);
    %At = A.';
    [~,out]=max(mask,[],2);
end

