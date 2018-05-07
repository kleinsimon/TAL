function [ V, I ] = findNearestValue( Needle, Haystack )
%[ V, I ] = findNearestValue( Needle, Haystack )

    s=size(Needle);
    V=nan(s);
    I=nan(s);

    for i=1:numel(Needle)
        [~, I(i)] = min(abs(Haystack-Needle(i)));
        V(i)=Haystack(I(i));
    end
end

