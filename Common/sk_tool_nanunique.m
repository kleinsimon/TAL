function [u] = sk_tool_nanunique(x)
  t = rand;
  while any(x(:)==t)
      t = rand;
  end
  x(isnan(x)) = t;
  u=unique(x);
  u(u==t)=nan;
end