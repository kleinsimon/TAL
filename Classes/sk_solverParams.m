classdef sk_solverParams
    %solverParams Holds parameters needed for numeric optimization
    %   Detailed explanation goes here
    
    properties
        x0;
        %x0 Startvalue
        A;
        %A linear inequalities, ax + by + cz
        b;
        %b Limit of linear inequalities A <= xx
        Aeq;
        %Aeq linear equalities, ax + by + cz
        beq; 
        %beq Limit of linear equalities A <= xx
        lb;
        %lower bounds
        ub; 
        %upper bounds
        nonlcon;
        %Nonlinear constraint function
        dim;
    end
    
    methods
        
        function obj = sk_solverParams(dim)
            obj.dim = dim;
            obj.x0 = zeros(1, dim);
            obj.A = ones(1, dim);
            obj.b = 1;
            obj.Aeq = [];
            obj.beq = [];
            obj.lb = zeros(1, dim);
            obj.ub = ones(1, dim);
            obj.nonlcon = [];
        end 
        
        function newobj = copy(obj)
            newobj = sk_solverParams(obj.dim);
            newobj.x0 = obj.x0;
            newobj.A = obj.A;
            newobj.b = obj.b;
            newobj.Aeq = obj.Aeq;
            newobj.beq = obj.beq;
            newobj.lb = obj.lb;
            newobj.ub = obj.ub;
            newobj.nonlcon = obj.nonlcon;
        end
        
        function ret = get.x0(obj)
            ret=sk_tool_resolve_var(obj.x0);
        end
        function ret = get.A(obj)
            ret=sk_tool_resolve_var(obj.A);
        end
        function ret = get.b(obj)
            ret=sk_tool_resolve_var(obj.b);
        end
        function ret = get.Aeq(obj)
            ret=sk_tool_resolve_var(obj.Aeq);
        end
        function ret = get.beq(obj)
            ret=sk_tool_resolve_var(obj.beq);
        end
        function ret = get.lb(obj)
            ret=sk_tool_resolve_var(obj.lb);
        end
        function ret = get.ub(obj)
            ret=sk_tool_resolve_var(obj.ub);
        end
    end
end

