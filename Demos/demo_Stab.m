%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Demonstrates the calculation of fcc stability by adding Si3N4. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% System init

tcsys = sk_tc_system;
tcsys.Database='TCFE7';
tcsys.Elements='Fe Cr v si n c mo mn ni';
tcsys.RejPhases='*';
tcsys.ResPhases='sigma m23 laves m6c fcc bcc liquid gas';
tcsys.Init;

%% Conditions
initEq=tcsys.GetInitialEquilibrium;
conds = 'T=1323 P=1e8 N=1 W(cr)=0.1542 w(mn)=0.00843 w(c)=0.00009 w(ni)=0.00559 w(mo)=0.00972 w(v)=0.00282 w(n)=0.005864 w(si)=0.00967';
initEq.SetConditions(conds);

baseEq=initEq.Clone();

%% Get Stability as a Property
fun = sk_func_tc_properties(baseEq, 'dg("fcc","bcc")');

%% Use Standard function Solver with property as a function
% The preFunc is evaluated before submitting the Values. Using the
% following anonymous function. It takes the incoming N-Content and sets
% the apropriate Si- and N-Content

solvfun = sk_solver_eval_func;
solvfun.preFunc=@(vals,vars)(deal({'w(n)','w(si)', vals{2:end}}, [vars(1)*0.4, vars(1)*0.6, vars(2:end)]));
solvfun.zObjects=fun;

%% Variate N and Temperature 
mapper=sk_mapper;
mapper.Mode = 0;
mapper.zSolver = solvfun;
mapper.Components = {'w(si3n4)','t'};
mapper.Ranges={...
    [0, 0.1, 10],...  %N
    [800+273.15, 1200+273.15, 10],...  %T
    };

mapper.doMapping;

res=mapper.getResult();

%% Plot

stem3(res.w_si3n4_,res.t,res.dg__fcc___bcc__);
