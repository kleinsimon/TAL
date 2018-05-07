classdef sk_tool_progress_bar<handle
%Displays inline Status for a number of 0-1
%   
    properties
        statlen=20; %string length
        maxnum=1;
        curnum=0;
        winhandle;
    end
    methods
        function obj = sk_tool_progress_display(win)
            fprintf('%s', blanks(obj.statlen)); 
        end
        
        function incShow(obj)
            obj.curnum = obj.curnum + 1;
            obj.show(obj.curnum/obj.maxnum);
        end
        
        function show(obj, progress)
            fprintf(repmat('\b',1,obj.statlen));
            status=sprintf('%.3f%% complete', 100 * progress);
            fprintf('%s%s', status, blanks(obj.statlen-length(status)));
            if obj.curnum == obj.maxnum
                fprintf('\n');
            end
        end
    end
end

