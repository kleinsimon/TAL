function [ i ] = getZeroColumns( M )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    i = find(~any(M,1),1 );
end

