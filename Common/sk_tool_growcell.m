function [ C ] = sk_tool_growcell( C, next, dim )
    %sk_tool_growcell(Cell, nextIndex, dim=1)
    %Doubles the Size of Cellarray Cell in dimension dim, if nextIndex
    %outranges the current size

    cur=size(C, dim);
    if next > cur
        C{cur*2,:}=[];
    end
end

