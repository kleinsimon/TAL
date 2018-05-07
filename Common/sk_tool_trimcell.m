function [ C ] = sk_tool_trimcell( C )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

    C = C(~cellfun('isempty',C));
end

