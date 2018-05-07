classdef sk_tc_plotter
    properties
    end
    
    methods(Static)
        function resT = PlotPhaseContents(oeq, varargin)
            %PlotPhaseContents(EQ, startT=600°C, endT=1500°C, steps=40, modifier=vpv)
            
            [startT, endT, nstep, mod] = sk_tool_parse_varargin(varargin, 873.15, [], 40, 'vpv');
            
            eq = oeq.Clone;
            
            if isempty(endT)
                endT = eq.GetProperty('tliq')+5;
            end
            
            fun = sk_func_tc_properties(eq);
            fun.Properties={'phase_content'};
            
            solver = sk_solver_eval_func;
            solver.zObjects=fun;
            
            mapper = sk_mapper;
            mapper.Mode = 3;
            mapper.zSolver = solver;
            mapper.Components = {'t'};
            mapper.Ranges = {[startT, endT, nstep]};
            mapper.doMapping;
            
            res = cell2mat(mapper.Result);
            x=res(:,1) - 273.15;
            res(:,1) = [];
            
            empty = sum(res,1) < 1e-8;
            
            names = eq.GetPhases;
            names(empty)=[];
            res(:,empty)=[];
            
            for i=1:length(names)
                plot(x, res(:,i), 'DisplayName', names{i});
                hold on;
            end
            xlabel('Temperature [°C]');
            ylabel(sprintf('Content [%s]', mod));
            legend(names, 'Interpreter', 'none');
            hold off;
            
            resT = array2table([x,res]);
            resT.Properties.VariableNames = ['T', names];
        end        
    end    
end

