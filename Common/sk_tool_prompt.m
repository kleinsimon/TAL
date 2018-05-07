function res = sk_tool_prompt( prompt, default )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    ptmp = sprintf('%s [%s]:\t', prompt, default);
    res = input(ptmp, 's');
    if isempty(res)
        res=default;
    end
end

