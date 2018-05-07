function [ varargout ] = closest( C, n )
%[ index ] = closest( C, n )
%[ index, value ] = closest( C, n )
%Finds the value closest to n in an array.
%

    [~, index] = min(abs(C - n));
    
    varargout{1} = index;
    
    if nargout == 2
        varargout{2} = C(index);
    end
end

