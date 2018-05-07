function [ varargout ] = sk_tool_celldiff( cell1, cell2, varargin )
%[d1] = sk_tool_celldiff( cell1, cell2 )  return all Rows in cell1, which are not in cell2
%[d1,d2] = sk_tool_celldiff( cell1, cell2 )  return all Rows in cell1, which are
%not in cell2 (d1) and vice versa (d2)
%[d1,d2,i1,i2] = sk_tool_celldiff( cell1, cell2 )  also return the indexes of those rows
%[..] = sk_tool_celldiff( cell1, cell2, [Respect Case] )

    if isempty(varargin) || varargin{1}
        cell1=sk_tool_cellupper(cell1);
        cell2=sk_tool_cellupper(cell2);
    end
    
    c1 =cellfun(@num2str, cell1, 'un', 0);
    c2 =cellfun(@num2str, cell2, 'un', 0);
    i1 = zeros(0,1);
    d2 = zeros(0,1);
    i2 = 1:size(c2,1);
    
    for i=1:size(c1,1)
        ind=find(all(ismember(c2,c1(i,:)),2));
        if isempty(ind)
            i1(end+1,1) = i;
        else
            d2(end+1,1) = ind;
        end
    end
    
    i2(d2)=[];

    varargout{1}=cell1(i1,:);
    switch nargout
        case {2 3}
            varargout{2}=cell2(i2,:);
        case 4
            varargout{2}=cell2(i2,:);
            varargout{3}=i1;
            varargout{4}=i2;
    end
end

