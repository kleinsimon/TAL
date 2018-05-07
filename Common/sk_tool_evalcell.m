function sk_tool_evalcell( commands )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    for i=1:length(commands)
        eval(commands{i});
    end
end

