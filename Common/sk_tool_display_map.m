function sk_tool_display_map( inMap )
%sk_tool_display_map( map ) Displays Map in command window
    if ~isa(inMap, 'containers.Map')
        error ('inMap must be from Type containers.Map');
    end
   
    T = cell2table(inMap.values, 'VariableNames', matlab.lang.makeValidName(inMap.keys));
    disp (T);
end

