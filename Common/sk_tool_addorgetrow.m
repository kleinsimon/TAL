function [ A, row ] = sk_tool_addorgetrow( A, x, varargin)
%[ A, row ] = sk_tool_addorgetrow( A, x, cols)
%   Adds or gets a row, if not allready there... cols [from to] to look for
    Asize=size(A);
    xsize=size(x);

    if nargin() == 2 && Asize(2) ~= xsize(2)
        error('Row length does not match');
    end
    index=0;
    
    if size(A,1)~=0
        if length(varargin) == 1
            cols=varargin{1};
            [~,index]=ismember(x,A(:,cols(1):cols(2)),'rows');
        else
            [~,index]=ismember(x,A(:,:),'rows');
        end
    end
    
    if index ~= 0 %Allready there
        row=index;
        return;
    else %not there, add
        if length(x)<Asize(2)
            x(1,Asize(2)) = NaN;
        end
        A = [A; x];
        row=size(A,1);
        return;
    end
end

