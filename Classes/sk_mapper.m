
classdef sk_mapper<handle
    %mappingHelper Maps data derived from function over a given input range
    %   Components: Cellarray of TC-Name of Variables to be mapped at x axis (eg. {T, w(c)})
    %   Ranges:     Cellarray of Vectors for Range per axis {[Start, End, Number of Steps],..}
    %   zFunction:    Solver to call at each point (Superclass sk_solvers)
    %   Mode:       0=map in all n dimensions; 
    %               1=map all variables 2-D against the first variable;
    %               2=map all variables in all combinations, n choose 2
    %               3=step all variables individually
    
    properties(Access = private)
        zFunction   %Solver to call at each point (Superclass sk_solvers)
        skipWatchdog %sk_funcs to use to evaluate a stop condition
        skipCheckFun %Function to check the result of the watchdog to stop the current iteration
    end
    
    properties(SetAccess = private, GetAccess = public)
        Result={};
        Header={};
    end
    
    properties
        Components={};  %Variables to variate. eg 'w(c)' etc. Cellarray.
        Ranges={}; %Cellarray of 1x3 Arrays. Each array denotes start, end and step {[1 10 1], [1 20 1]}. One Range for each component is needed.
        zSolver; %sk_solvers which to call on every iteration point
        Mode=0;  %0=map in all n dimensions;  1=map all variables 2-D against the first variable; 2=map all variables in all combinations, n choose 2; 3=step all variables individually       
    end
    
    methods
        function obj=sk_mapper()
           
        end
        
        function setup(obj, Components, Ranges, zSolver, Mode)
            %setup(Vars, Ranges, zObject, zNames)
            obj.Components = Components;
            obj.Ranges = Ranges;
            obj.zSolver = zSolver;
            obj.Mode = Mode;
        end
        
        % doMapping Starts the mapping process
        function doMapping(obj)
            if length(obj.Ranges) ~= length(obj.Components)
                error('Number of ranges does not match number of components!');
            end
            if ~isa(obj.zSolver, 'sk_solvers')
                error('Solver must be inherited from superclass sk_solvers')
            end

            solver = obj.zSolver;
            obj.zFunction = @solver.calculate;
            mString={'0=one map with n dimensions','1=n-1 maps with 2 dimensions against first Variable', '2=n choose 2 maps with all variations of the given variables', '3=n maps with 1 dimension (Stepping)'};
            fprintf('Starting mapping with mode %s \n', mString{obj.Mode+1});
            switch obj.Mode
                case 0
                    obj.Result = obj.doMappingAll(obj.Components, obj.Ranges);
                    obj.Header = [obj.Components, obj.zSolver.output_names];
                case 1
                    obj.Result = obj.doMapping2D(obj.Components, obj.Ranges);
                case 2
                    obj.Result = obj.doMappingComb(obj.Components, obj.Ranges);
                case 3
                    obj.Result = obj.doStepping(obj.Components, obj.Ranges);
            end
        end
        
        function tbl = getResult(obj)
            names = matlab.lang.makeValidName(cellflat(obj.Header));
            if length(names)~=size(obj.Result,2)
                fprintf ('Number of headers (%i) does not match number of columns (%i)\n', length(names), size(obj.Result,2));
            else
                tbl=cell2table(obj.Result, 'VariableNames', names);
                tbl.Properties.VariableDescriptions = cellflat(obj.Header);
            end
        end
        
        function h = plot(obj)
            switch obj.Mode
                case 0
                    fh=figure(1);
                    view([45,30]);
                    tmp = cell2mat(obj.Result);
                    x=tmp(:,1);
                    y=tmp(:,2);
                    z=tmp(:,3);
                    tri = delaunay(x,y);
                    hold on;

                    trisurf(tri, x, y, z,'FaceColor','interp','EdgeColor','none');
                    grid on;
                    
                    axis vis3d;
                    
                    zoom(fh);
                    
                    c=colorbar;
                    Surf = {tri,[x y z]}; 
                    %[H,V]= IsoLine(Surf,z,[0 0]);
                    xlabel(obj.Header{1},'Interpreter','latex');
                    ylabel(obj.Header{2},'Interpreter','latex');
                    ylabel(c,obj.Header{3},'Interpreter','latex');
                    zlabel(obj.Header{3},'Interpreter','latex');
                    hold off;
                case 3
                    fh=figure(1);
                    tmp = cell2mat(obj.Result);
                    x=tmp(:,1);
                    y=tmp(:,2:end);
                    plot(x,y);
            end
        end
    end
    
    methods (Access = private)
        
        function res = doMappingAll(obj, Components, Ranges)  %mode 0
            obj.zSolver.Components = Components;
            dimension=length(Ranges);
            if (dimension < 2)
                error('This mode for mapping requires at least 2 degrees of freedom');
            end
            inputArrays=cell(1, dimension);
            for dim=1:dimension
                inputArrays{dim} = linspace(Ranges{dim}(1),...
                    Ranges{dim}(2),Ranges{dim}(3));
            end
            tmp = sk_tool_loop_func(inputArrays, obj.zFunction);
            res = vertcat(tmp{:});
        end
        
        function res = doMapping2D(obj, Components, Ranges) % mode 1
            dimension=length(Ranges);
            if (dimension < 2)
                error('This mode for mapping requires at least 2 degrees of freedom');
            end
            
            rtmp = {};
            obj.Header={};
            for dim=2:dimension
                axe1=sprintf('%s_%i', obj.Components{1}, dim-1);
                axe2=obj.Components{dim};
                fprintf('Map %i of %i, %s+%s\n', dim-1, dimension-1, axe1, axe2);
                axes=cellfun(@(c)(sprintf('%s_%s_%s',obj.Components{1}, obj.Components{dim}, c)), obj.zSolver.output_names, 'UniformOutput', false);
                obj.Header=[obj.Header, axe1, axe2, axes];
                
                tmp = obj.doMappingAll({Components{1}, Components{dim}}, {Ranges{1}, Ranges{dim}});
                rtmp = [rtmp, tmp];
            end
            res = rtmp;
        end
        
        function res = doMappingComb(obj, Components, Ranges)
            n = length(obj.Ranges);
            if (n < 2)
                error('This mode for mapping requires at least 2 degrees of freedom');
            end
            
            indexes = 1:n;
            pairs = combnk(indexes,2);
            dimension = length(pairs);
            rtmp = {};
            for dim=1:dimension
                axe1=sprintf('%i_%s', dim-1, obj.Components{pairs(dim,1)});
                axe2=sprintf('%i_%s', dim-1, obj.Components{pairs(dim,2)});
                fprintf('Map %i of %i, %s+%s\n', dim, dimension, axe1, axe2);
                axes=cellfun(@(c)(sprintf('%s_%s_%s', obj.Components{pairs(dim,1)}, obj.Components{pairs(dim,2)}, c)), obj.zSolver.output_names, 'UniformOutput', false);
                
                obj.Header=cellflat([obj.Header, axe1, axe2, axes]);
                
                tmp = obj.doMappingAll({Components{pairs(dim,1)},Components{pairs(dim,2)}}, {Ranges{pairs(dim,1)}, Ranges{pairs(dim,2)}});
                rtmp = [rtmp, tmp];
            end
            res = rtmp;
        end
        
        function res = doStepping(obj, Components, Ranges)
            solver = obj.zSolver;
            obj.zFunction = @solver.calculate;
            dimension=length(Ranges);

            lengths=cellfun(@(x)(x(3)),Ranges);
            all = sum(lengths);
            maxlen = max(lengths);
            progDisp=sk_tool_progress_display(all);
            %[~, oldCond] = tc_list_conditions;
            wd =false;
            if isa(obj.skipWatchdog, 'sk_funcs')
                wd=true;
            end
            
            rtmp=cell(maxlen,0);
            
            for dim=1:dimension
                tmpH{1} = Components{dim};
                fprintf('## Stepping component %s\n', Components{dim});
                names = obj.zSolver.output_names;
                for oi=1:length(obj.zSolver.output_names)
                    tmpH{1+oi} = sprintf('%s:%s',Components{dim},names{oi});
                end
                obj.Header=[obj.Header,tmpH];
                %sk_tc_set_conditions(oldCond);
                obj.zSolver.Components=Components(dim);
                inputValues = linspace(Ranges{dim}(1),...
                    Ranges{dim}(2),Ranges{dim}(3));

                n=length(inputValues);
                dimX = cell(maxlen,1);
                dimY = [];
                for val=1:n
                    %sb = sk_tc_sandbox;
                    dimX{val,1} =inputValues(val);
                    r = obj.zFunction(inputValues(val));
                    results = cellflat(r);
                    if isempty(dimY)
                        dimY = cell(maxlen,length(results));
                    end
                    for ri=1:length(results)
                        dimY(val,ri) = results(ri);
                    end
                    progDisp.incShow();
                    %sb.Restore;
                end
                rtmp=[rtmp, dimX, dimY];
            end
            res = rtmp;
            obj.zSolver.Components = Components;
            %sk_tc_set_conditions(oldCond);
        end
    end
end

