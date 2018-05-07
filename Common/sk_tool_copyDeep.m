function [ newobj ] = sk_tool_copyDeep( obj )
    objByteArray = getByteStreamFromArray(obj);
    newobj = getArrayFromByteStream(objByteArray);
end

