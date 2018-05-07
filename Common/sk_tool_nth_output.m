function value = sk_tool_nth_output(fcn,N,varargin)
  [value{1:N}] = fcn(varargin{:});
  value = value{N};
end