classdef sk_conditionFinder < handle
    %Finds the spot, where a given function turns from false to true,
    %either up or down.

    properties
        Func;   %Function to evaluate. Must accept a value and return true or false
        Xmin;   %Minimum of the range to check
        Xmax;   %Maximum of the range to check
        DirectionDown=false;    %Search from max to min instead of min to max
        OrderRange=3;   %Max ORder of magnitudes. Will start at the highest order and lower it until reaching the tolerance
        OrderStep=1;  %Reduce the order by this step
        Tolerance=0.1; %X-Tolerance to allow
        Verbose=0;  %Give report
    end

    properties (Access=private)
        count=0;
        step=0;
    end

    methods
        function obj=sk_conditionFinder()
        end

        function [x] = calculate(obj)
            if ~isa(obj.Func, 'function_handle')
                error("no function provided");
            end

            start = obj.Xmin;

            %invert Step if going down
            if obj.DirectionDown
                start = obj.Xmax;
            end

            curOrder = obj.OrderRange;
            x = start;
            if obj.resolve(x)
                error("Function already satisfied at xstart")
            end

            while curOrder >= 0
                obj.step = (obj.Tolerance/2) * 10^curOrder;
                if obj.DirectionDown
                    obj.step = -obj.step;
                end
                while ~obj.resolve(x+obj.step)
                    x = x+obj.step;

                    if x>=obj.Xmax || x<=obj.Xmin
                        warning("nothing found");
                        return
                    end
                end
                curOrder=curOrder-obj.OrderStep;
            end
            if obj.Verbose
                fprintf("=== %g steps taken \n", obj.count);
            end
        end

        function b = resolve(obj, x)
            if obj.Verbose
                fprintf("Step: %g => x: %g \n",obj.step,x);
            end
            obj.count=obj.count+1;
            b=obj.Func(x);
        end
    end
end