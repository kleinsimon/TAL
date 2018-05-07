function [ M ] = removeZeroColumns( M )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    M( :, ~any(M,1) ) = [];
end

