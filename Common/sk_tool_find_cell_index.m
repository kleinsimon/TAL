function [ Index ] = sk_tool_find_cell_index( CellArray, Str )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    Index=-1;
    for i=1:length(CellArray)
        if strcmp(CellArray{i}, Str)
            Index = i;
            return;
        end
    end
end

