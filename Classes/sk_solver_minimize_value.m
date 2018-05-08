classdef sk_solver_minimize_value < sk_solvers

    properties
        Components={};
        %%%
        varComponents;
        %x0, A, b, Aeq, beq, lb, ub, nonlcon;
        solvParm;
        %minimization parameters
        options;
        %fmincon options
        silent=1;
        %surpress status messages
        minFunc;
        searchglobal = 0;
        %function handle for minimization comparison f(vec) = scalar
        invert=0;
        %Override Function. Can be a function to handle the result of minfunc 
        overrideFunc;
    end
    
    properties (Dependent)
        output_names;
    end
    
    properties (Access=private)
        counter=1;
        history=struct;
        searchdir = [];
    end
    methods
        
        function value = get.output_names(obj)
            value = cellflat({strjoin(obj.varComponents,'|'),obj.minFunc.zNames});
        end
        
        function obj = sk_solver_minimize_value() 
            
        end
        
        function setup(obj)
        end
               
        function res = calculate(obj, Values)
            if nargin == 1
                Values=[]; 
            end
            if obj.silent == 1
                obj.options = optimoptions('fmincon','Display','none','Diagnostics','off','TolX',1e-2,'Algorithm','interior-point','DiffMinChange', 1e-4);
            else
                obj.options = optimoptions('fmincon','Display','final','Diagnostics','off','TolX',1e-2,'Algorithm','interior-point','DiffMinChange', 1e-4);
            end
                       
            parm = obj.solvParm.copy();
            
            if obj.invert
                ftmp=@(xvec)(obj.minFunc.calculate([obj.varComponents obj.Components],[xvec Values])*-1);
            else
                ftmp=@(xvec)(obj.minFunc.calculate([obj.varComponents obj.Components],[xvec Values]));
            end
            
            if ~isempty(obj.overrideFunc)
                fh=@(xvec)(obj.overrideFunc(ftmp(xvec)));
            else
                fh=@(xvec)(ftmp(xvec));
            end
            
            if ~obj.searchglobal
                [x,fval,~,~,~,~,~] = ...
                    fmincon(fh,...
                    parm.x0,parm.A,parm.b,parm.Aeq,parm.beq,parm.lb,parm.ub,parm.nonlcon,...
                    obj.options);
            else
                problem = createOptimProblem('fmincon','objective',fh, ...
                    'x0',parm.x0, 'Aineq', parm.A, 'bineq', parm.b, 'Aeq', parm.Aeq, ...
                    'beq', parm.beq, 'lb', parm.lb, 'ub', parm.ub, 'nonlcon', parm.nonlcon, ...
                    'options', obj.options);

                gs = GlobalSearch;
                [x, fval] = gs.run(problem);
            end

            if obj.invert
                res = {x, fval*-1};
            else
                res = {x, fval};
            end
        end
        
        
        
        function selfCheck(obj)
            if (~isa(obj.solvParm,'sk_solverParams'))
                error('Solver Parameters not defined. Pass solverParams object to solvParm.');
            end
%             def = sk_tc_get_defined_contents({},'w');
%             warning('Defined Contents bigger than 1. (%d)', def);
%             if (def>=1.0)
%                 warning('Defined Contents bigger than 1. (%d)', def);
%             end
            if (~isa(obj.minFunc,'sk_funcs'))
                error('No comparsion function defined. Give sk_funcs object to minFunc.');
            end
        end
        
        function stop = printOutput(obj,x,optimValues,state)
%             varElm = obj.varComponents;
%             stop = false;
%             sk_tc_set_conditions_for_component(varElm, x);
%             sk_tc_compute_equilibrium_safe;
%             [mainPhase, content] = sk_tc_find_stable_main_phase();
%             [numElm, Elm] = tc_list_component;
%             varElm = obj.varComponents;
%             stop=0;
%             fW = 12;
%             switch state
%                 case 'init'
%                     hold on;
%                     disp ('____________________________________________________________');
%                     disp ('   Begining Iteration');
%                     disp ('____________________________________________________________');
%                     %PrintHeader(obj, varElm, Elm, fW)
%                     PrintHeader(obj, varElm, fW)
%                 case 'iter'
%                     %PrintRow(obj, x, varElm, Elm, mainPhase, content, OptimVars, fW)
%                     PrintRow(obj, x, varElm, OptimVars, fW)
%                 case 'done'
%                     disp ('____________________________________________________________');
%                     disp ('   End Iteration');
%                     disp ('   Result:');
%                     disp ('____________________________________________________________');
%                     %PrintHeader(obj, varElm, Elm, fW)
%                     %PrintRow(obj, x, varElm, Elm, mainPhase, content, OptimVars, fW)
%                     PrintHeader(obj, varElm, fW)
%                     PrintRow(obj, x, varElm, OptimVars, fW)
%                     disp ('____________________________________________________________');
%                     hold off;
%                 otherwise
%             end
            stop=0;
            switch state
                case 'init'
                    fprintf('Calculated Points: ');
                    fprintf('% 4s', ' ');
                    obj.counter=1;
                    obj.history.x = [];
                    obj.history.fval = [];
                    obj.searchdir = [];
                case 'iter'
                    fprintf('\b\b\b\b% 4d', obj.counter);
                    obj.counter = obj.counter + 1;
                    
                    obj.history.fval = [obj.history.fval; optimValues.fval];
                    obj.history.x = [obj.history.x; x];
                    %obj.searchdir = [obj.searchdir; optimValues.searchdirection'];
                    plot(x(1),x(2),'o');
                    hold on;
                    text(x(1)+.15,x(2),num2str(optimValues.iteration));  
                case 'done'
                    fprintf('\n');
                    hold off;
            end
        end       

        function PrintHeader(obj,varElm, Elm, fW)
            sk_tool_xprintf('Iter',[],6);
            for i=1:length(varElm)
                sk_tool_xprintf('%s', varElm{i}, fW);
            end
            sk_tool_xprintf('Result',[],fW);
            sk_tool_xprintf('Main Phase',[],fW);
            sk_tool_xprintf('np',[],fW);
            for i=1:length(Elm)
                if (strcmp(Elm{i}, 'VA')), continue, end;
                sk_tool_xprintf('%s [at%%]', Elm{i}, fW);
            end
            fprintf('\n');
        end

        function PrintRow(obj,x, varElm, Elm, mainPhase, content, OptimVars, fW)
            sk_tool_xprintf('%d', OptimVars.iteration, 6);
            for i=1:length(x)
                sk_tool_xprintf('%.4f', x(i), fW);
            end
            sk_tool_xprintf('%.4f', OptimVars.fval, fW)
            sk_tool_xprintf('%s', mainPhase, fW)
            sk_tool_xprintf('%.4f', content, fW);
            for i=1:length(Elm)
                if (strcmp(Elm{i}, 'VA')), continue, end;
                CurCont = tc_get_value(sprintf('x(%s,%s)', mainPhase, Elm{i})) * 100;
                sk_tool_xprintf('%.4f', CurCont, fW);
            end
            fprintf('\n');
        end
    end
end