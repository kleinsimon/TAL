function [ varargout ] = sk_tool_callfuncs( varargin )
%Calls all given functions and returns the result of the last one
%each Cell can contain either a Function handle or a cellarray of the
%number of output variables, the handle and input parameters. The Number
%of output variables can be omitted, if zero
% eg. {0, @disp, 'Hello World'} or {@disp, 'Hello World'} 
%If nothing should be returnd, pass [] as the last parameter

    out = cell(0,1);

    for i=1:numel(varargin);
        f=varargin{i};
        if isa(f,'function_handle')
            f();
        elseif isa (f, 'cell')
            if ~isa(f{1},'function_handle')
                n=f{1};
                s=3;
                ff=f{2};
            else
                n=0;
                s=2;
                ff=f{1};
            end
            if n == 0
                ff(f{s:end});
            else
                r = cell(1,n);
                r{:} = ff(f{s:end});
                out = [out, r];
            end
        else
            error('wrong parameter');
        end
    end
    
    varargout = out;
end

