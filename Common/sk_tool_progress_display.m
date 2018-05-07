classdef sk_tool_progress_display<handle
%Displays Status Bar Dialog for a number of 0-1
%   
    properties
        statlen=20; %string length
        maxnum=1;
        curnum=0;
        winhandle;
        finishup;
        starttime;
    end
    methods
        function obj = sk_tool_progress_display(maxnum)
            obj.maxnum=maxnum;
            h = waitbar(0,sprintf('Iterating %d values...',maxnum));
            obj.winhandle = h;
            obj.finishup = onCleanup(@() obj.CleanUp(h));
            obj.starttime=tic;
        end
        
        function incShow(obj, varargin)
            if nargin==2
                incr=varargin{1};
            else
                incr=1;
            end
            obj.curnum = obj.curnum + incr;
            obj.show(obj.curnum/obj.maxnum);
            
            if obj.curnum == obj.maxnum
                delete(obj.winhandle);
            end
        end
        
        function show(obj, progress)
            dur = datestr(datenum(0,0,0,0,0,toc(obj.starttime)), 'HH:MM:SS');
            waitbar(...
                progress, ...
                obj.winhandle, ...
                sprintf('Iteration %i/%i... %.1f%% (%s)',obj.curnum, obj.maxnum, progress*100, dur)...
            );
        end
        
        function CleanUp(obj, h)
            delete(h);
        end
    end
end

