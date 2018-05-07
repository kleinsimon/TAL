function resMap = sk_tool_fill_map( inMap, Elements, Default )
%sk_tool_fill_map( inMap, Elements, Default ) Fills a container.Map with missing Elements and a default Value
%   inMap:    Map to fill
%   Elements: Elements do create when missing
%   Default: Default value for new Elements

    if ~isa(inMap, 'containers.Map')
        error ('inMap must be from Type containers.Map');
    end
    
    for i=1:length(Elements)
        if ~inMap.isKey(Elements{i})
            inMap(Elements{i}) = Default;
        end
    end
    resMap = inMap;
end

