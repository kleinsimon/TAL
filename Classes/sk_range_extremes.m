classdef sk_range_extremes<handle
    %mappingHelper Maps data derived from function over a given input range
    %   Components: Cellarray of TC-Name of Variables to be mapped at x axis (eg. {T, w(c)})
    %   Ranges:     Cellarray of Vectors for Range per axis {[Start, End, Number of Steps],..}
    %   zSolver:    Solver to call at each point (Superclass tc_functions)
    %   Mode:       0=map in all n dimensions; 
    %               1=map all variables 2-D against the first variable;
    %               2=map all variables in all combinations, n choose 2
    %               3=step all variables individually
    
    properties(Access = private)
        zFunction;
        Dim;
    end
    
    properties(SetAccess = private, GetAccess = public)
        Result={};
        Header={};
        zSolver;
        Combs;
        Extremes;
        ExtremeIndices;
        ResTable;
    end
    
    properties
        Components={};
        minComp={};
        maxComp={};
        zObjects;
        Mode=2;
    end
    
    methods
        function obj=sk_range_extremes()
            obj.zSolver=sk_solver_eval_func;
        end
        
        function set.zObjects(obj, val)
            if isa(val,'cell')
                obj.zObjects=val;
                obj.Dim=length(val);
            else
                obj.zObjects={val};
                obj.Dim=1;
            end
        end
               
        function calculate(obj)
            obj.getVarNames;
            switch obj.Mode
                case 1
                    obj.doCalculateExtremes;
                case 2
                    obj.doCalculateSolver;
            end
        end
            end
    
    methods (Access = private)
        function getVarNames(obj)
            for i=1:obj.Dim
                obj.Header{end+1}=obj.zObjects{i}.zNames;
            end
        end
        
        function doCalculateExtremes (obj)
            obj.zSolver.zObjects=obj.zObjects;
            obj.zSolver.Components=obj.Components;
            solver = obj.zSolver;
            obj.zFunction=@solver.calculate;
            
            obj.getCombs;
            rows=size(obj.Combs,1);
            res = NaN(rows,length(obj.zObjects));
            
            progDisp=sk_tool_progress_display(rows);
            for i = 1:rows
                s=obj.Combs(i,:);
                r=obj.zFunction(s);
                
                res(i,:)=vertcat(r{:});
                progDisp.incShow();
            end
            obj.Result=res;
            
            tbl=struct;
            for i=1:obj.Dim
                tbl(i).Var=obj.Header{i};
                tbl(i).Min=min(obj.Result(:,i));
                mini=find(obj.Result(:,i)==tbl(i).Min);
                tbl(i).MinInput=obj.Combs(mini,:);
                tbl(i).Max=max(obj.Result(:,i));
                maxi=find(obj.Result(:,i)==tbl(i).Max);
                tbl(i).MaxInput=obj.Combs(maxi,:);
            end
            obj.ResTable=struct2table(tbl);
        end
        
        function doCalculateSolver (obj)
            solv = sk_solver_minimize_value;
            %solv.Components=obj.Components;
            solv.varComponents=obj.Components;
            p = sk_solverParams(length(obj.Components));
            m = [obj.minComp;obj.maxComp];
            cmin = min(m,[],1);
            cmax = max(m,[],1);
            p.x0=cmin+(cmax-cmin)/2;
            p.lb=cmin;
            p.ub=cmax;
            solv.solvParm=p;
            solv.searchglobal=0;
            solv.silent=0;
            obj.Result=cell(obj.Dim,1);
            tbl=struct;
            
            for i=1:obj.Dim
                solv.minFunc=obj.zObjects{i};
                h=cellflat(obj.Header);
                vName=h{i};
                fprintf('----------------\nSearching minimum of %s\n----------------\n', vName);
                solv.invert=0;
                rmin = solv.calculate([]);
                fprintf('----------------\nSearching maximum of %s\n----------------\n', vName);
                solv.invert=1;
                rmax = solv.calculate([]);
                
                tbl(i).Var=vName;
                tbl(i).Min=rmin{2};
                tbl(i).MinInput=rmin{1};
                tbl(i).Max=rmax{2};
                tbl(i).MaxInput=rmax{1};
            end
            obj.ResTable=struct2table(tbl);
        end
        
        function getCombs(obj)
            combs = sk_tool_allsets(length(obj.Components));
            ma = repmat(obj.maxComp,size(combs,1),1);
            mi = repmat(obj.minComp,size(combs,1),1);
            tmp(combs)=ma(combs);
            tmp(~combs)=mi(~combs);
            obj.Combs = reshape(tmp, size(combs));
        end
    end
end

