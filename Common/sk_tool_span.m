function ret = sk_tool_span(format, x, l)
    if (nargin < 3)
       l = 8; 
    end
    s = sprintf(format, x);
    mis = l - length(s);
    if (mis > 0)
        ret = [s, blanks(mis)];
        return;
    end
    ret = x;
end