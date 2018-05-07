function [ varargout ] = sk_tool_cellintersect( cell1, cell2, varargin )
%[d1] = sk_tool_cellintersect( cell1, cell2 )                Return rows in first cell
%[d1, d2] = sk_tool_cellintersect( cell1, cell2 )            Include rows of second cell
%[d1, d2, i1, i2] = sk_tool_cellintersect( cell1, cell2 )    Include indices of found rows
%[..] = sk_tool_cellintersect( cell1, cell2, [Respect Case] )
%return all Rows in cell1, which are also in cell2

    if isempty(varargin) || varargin{1}
        cell1=sk_tool_cellupper(cell1);
        cell2=sk_tool_cellupper(cell2);
    end

    c1 =cellfun(@num2str, cell1, 'un', 0);
    c2 =cellfun(@num2str, cell2, 'un', 0);
    del = zeros(0,1);
    del2 = zeros(0,1);
    
    for i=1:size(c1,1)
        ind=find(all(ismember(c2,c1(i,:)),2));
        if ~isempty(ind)
            del(end+1,1) = i;
            del2(end+1,1) = ind;
        end
    end
    
    
    varargout{1}=cell1(del,:);
    switch nargout
        case {1 2 3}
            varargout{2}=cell2(del2,:);
        case 4
            varargout{2}=cell2(del2,:);
            varargout{3}=del;
            varargout{4}=del2;
    end
end

