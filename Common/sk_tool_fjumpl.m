function sk_tool_fjumpl( fid, l )
%sk_tool_fjumpl( fid, l ) Jump to line l
    fseek(fid, 0, 'bof');
    for i=1:l-1
        fgets(fid);
    end
end

