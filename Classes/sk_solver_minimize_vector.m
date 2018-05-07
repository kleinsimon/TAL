classdef sk_solver_minimize_vector < sk_solvers

    properties
        Components;
        %%%
        varComponents;
        %x0, A, b, Aeq, beq, lb, ub, nonlcon;
        numResults;
        %Length of the resulting vector
        solvParm;
        %minimization parameters
        options;
        %fmincon options
        silent=1;
        %surpress status messages
        minFunc;
        %function handle for minimization comparison f(vec) = vec
    end
    properties (Dependent)
        output_names;
    end
    
    methods
        function value = get.output_names(obj)
            value = {strjoin(obj.varComponents,'|'),'Result','Main Phase','Main Phase Content','Contents of Main Phase'};
        end
        
        function obj = sk_solver_minimize_vector() 
            
        end
        
        function setup(obj)
        end
               
        function res = calculate(obj, Values)
            obj.options = gaoptimset('PopulationSize',60, 'ParetoFraction',0.7,'PlotFcns',@gaplotpareto,'Display','iter');
            
            for i=1:length(obj.Components)
                tc_set_condition(obj.Components{i}, Values(i));
            end
            obj.selfCheck();
            
            parm = obj.solvParm.copy();
            x=0;
            fval=0;

            [x,fval,flag,output,population] = gamultiobj(@(xvec)obj.minFunc.calculate(obj.varComponents,xvec),length(obj.varComponents),...
                          parm.A,parm.b,parm.Aeq,parm.beq,parm.lb,parm.ub,parm.nonlcon,obj.options);
            
            [mainph, content] = sk_tc_find_stable_main_phase();
                cnt = sk_tc_values_in_phase(mainph, 'x');
            %
            fprintf('Solver exited. Exitflag: %s\n',flag);
            fprintf('%d minima found.', length(x));
            res = {x, fval, mainph, content, strjoin(cnt,';')};
        end
        
        function selfCheck(obj)
            if (~isa(obj.solvParm,'solverParams'))
                error('Solver Parameters not defined. Pass solverParams object to solvParm.');
            end
%             def = sk_tc_get_defined_contents({},'w');
%             warning('Defined Contents bigger than 1. (%d)', def);
%             if (def>=1.0)
%                 warning('Defined Contents bigger than 1. (%d)', def);
%             end
            if (~isa(obj.minFunc,'function_handle'))
                error('No comparsion function defined. Give @handle to minFunc.');
            end
        end
        
        function stop = printOutput(obj,x,OptimVars,state)
            varElm = obj.varComponents;
            stop = false;
            sk_tc_set_conditions_for_component(varElm, x);
            sk_tc_compute_equilibrium_safe;
            [mainPhase, content] = sk_tc_find_stable_main_phase();
            [numElm, Elm] = tc_list_component;
            fW = 12;
            switch state
                case 'init'
                    hold on;
                    disp ('____________________________________________________________');
                    disp ('   Begining Iteration');
                    disp ('____________________________________________________________');
                    PrintHeader(obj, varElm, Elm, fW)
                case 'iter'
                    PrintRow(obj, x, varElm, Elm, mainPhase, content, OptimVars, fW)
                case 'done'
                    disp ('____________________________________________________________');
                    disp ('   End Iteration');
                    disp ('   Result:');
                    disp ('____________________________________________________________');
                    PrintHeader(obj, varElm, Elm, fW)
                    PrintRow(obj, x, varElm, Elm, mainPhase, content, OptimVars, fW)
                    disp ('____________________________________________________________');
                    hold off;
                otherwise
            end
        end

        function PrintHeader(obj,varElm, Elm, fW)
            sk_tool_xprintf('Iter',[],6);
            for i=1:length(varElm)
                sk_tool_xprintf('%s [ma%%]', varElm{i}, fW);
            end
            sk_tool_xprintf('Result',[],fW);
            sk_tool_xprintf('Main Phase',[],fW);
            sk_tool_xprintf('np [vol%%]',[],fW);
            for i=1:length(Elm)
                if (strcmp(Elm{i}, 'VA')), continue, end;
                sk_tool_xprintf('%s [at%%]', Elm{i}, fW);
            end
            fprintf('\n');
        end

        function PrintRow(obj,x, varElm, Elm, mainPhase, content, OptimVars, fW)
            sk_tool_xprintf('%d', OptimVars.iteration, 6);
            for i=1:length(x)
                sk_tool_xprintf('%.4f', x(i)*100, fW);
            end
            sk_tool_xprintf('%.4f', OptimVars.fval, fW)
            sk_tool_xprintf('%s', mainPhase, fW)
            sk_tool_xprintf('%.4f', content * 100, fW);
            for i=1:length(Elm)
                if (strcmp(Elm{i}, 'VA')), continue, end;
                CurCont = tc_get_value(sprintf('x(%s,%s)', mainPhase, Elm{i})) * 100;
                sk_tool_xprintf('%.4f', CurCont, fW);
            end
            fprintf('\n');
        end
    end
end