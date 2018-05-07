classdef sk_solver_eval_func < sk_solvers
    %sk_solver_eval_func Solver for sk_mapper to simply evaluate one ore
    %multiple functions at every point. 
    %
    %   zObjects:       Cellarray of objects from superclass sk_funcs to
    %                   evaluate at each point
    properties
        Components;     %set by mapper
        zObjects;
        output_names;   %set automatically
        preFunc;        %Function to evaluate before submitting to zObjects
        postFunc;       %Function to evaluate after submitting to zObjects
    end
        
    methods
        function obj = sk_solver_eval_func() 
            
        end
        
        function setup(obj, Components, func)
            obj.Components = Components;
            obj.zObjects = func;
        end
        
        function set.zObjects(obj, f)
            if (~iscell(f))
                obj.zObjects = {f};
            else
                obj.zObjects = f;
            end
            
            if ~all(cellfun(@(c)(isa(c, 'sk_funcs')), obj.zObjects))
                error ('zObjects must be of type sk_funcs or a cell array of sk_funcs');
            end
        end
        
        function res = get.output_names(obj)
            res = cellflat(cellfun(@(f)(f.zNames),obj.zObjects, 'UniformOutput', false));
        end
        
        function res = calculate(obj, values)
            l=length(obj.zObjects);
            res = cell(1,l);
            vars=obj.Components;
            vals=values;
            if isa(obj.preFunc,'function_handle')
                [vars, vals]=obj.preFunc(vars,vals);
            end
            
            for i=1:l
                if isa(obj.zObjects{i},'sk_funcs')
                    if isa(obj.postFunc,'function_handle')
                        res{1,i} = obj.postFunc(obj.zObjects{i}.calculate(vars, vals));
                    else
                        res{1,i} = obj.zObjects{i}.calculate(vars, vals);
                    end
                end
            end
            if isempty(obj.output_names)
                obj.output_names = cellflat(obj.output_names);
            end
        end
    end
end