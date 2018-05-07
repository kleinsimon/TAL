function [ O ] = getRange( A, Start, Width)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    End = Start + Width-1;
    O = A(Start(1):End(1),Start(2):End(2),Start(3):End(3));
end

