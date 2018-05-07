function result=sk_tool_loop_func(values, func)
%sk_tool_loop_func(values, func)
%Loops over a given CellArray of n Arrays with descrete values and
%returns a n-dimensional array with the result of a given function.
%   values:     cellarray{vec1,...,vecN}. Vectors can have different sizes
%   func:       Function handle to evaluate at each point. Must accept a
%               N-Dimensional vector containing the corresponding values
%               and a additional parameter given by parm
%   result:     cellarray of the results from function func

    dimension=length(values);
    all = prod(cellfun(@length, values));
    resVec=cell(all,1);
    posVec=num2cell(ones(1,dimension));
    progDisp=sk_tool_progress_display(all);
    result=loopRec(resVec, values, posVec, 1, func, progDisp);
end

function result=loopRec(result, values, position, dim, func, progDisp)
    maxdim=length(values);
    for x=1:length(values{dim})
        if dim<maxdim
            result=loopRec(result, values, position, dim+1, func, progDisp);
        else
            valVec = cellfun(@(v,i) v(i), values, position);
            indx = sub2ind(cellfun(@length, values), position{:});
            sb = sk_tc_sandbox;
            result{indx} = cellflat([num2cell(valVec), func(valVec)]);
            sb.Restore;
            progDisp.incShow();
        end
        position{dim}=position{dim}+1;
    end
end
