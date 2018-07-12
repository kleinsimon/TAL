classdef sk_conditionFinder < handle
    %Finds the spot, where a given function turns from false to true,
    %either up or down.
    
  properties
    func;   %Function to evaluate. Must accept a value and return true or false
    xmin;   %Minimum of the range to check
    xmax;   %Maximum of the range to check
    directionDown=false;    %Search from max to min instead of min to max
    orderRange=3;   %Max ORder of magnitudes. Will start at the highest order and lower it until reaching the tolerance
    tolerance=0.1; %X-Tolerance to allow
    verbose=0;  %Give report
  end

  methods
    function obj=sk_conditionFinder()
    end
  
    function [x] = calculate(obj)
      if ~isa(obj.func, 'function_handle')
        error("no function provided");
      end
            
      start = obj.xmin;
      
      %invert Step if going down
      if obj.directionDown
        start = obj.xmax;
      end

      curOrder = obj.orderRange;
      step = 0;
      x = start;
      if obj.func(x)
        error("Function already satisfied at xstart")
      end
      n=1;
      
      while curOrder >= 0
        while ~obj.func(x)
          step = (obj.tolerance/2) * 10^curOrder;
          if obj.directionDown
            step = -step;
          end
          x = x+step;
          if obj.verbose
            fprintf("Step: %g => x: %g \n",step,x);
          end
          if x>=obj.xmax
            warning("nothing found");
            return
          end
          n=n+1;
        end
        x = x-step;
        curOrder=curOrder-1;
      end
      if obj.verbose
        fprintf("=== %g steps taken \n", n);
      end
    end
  end
end