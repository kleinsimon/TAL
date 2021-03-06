%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Demonstrates the usage of a minimizer as a stepping target to the mapper
% Here, for a range of Cr-Contents the C-Content with the highest Delta-G is
% searched
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% System Initialization

tcsys = sk_tc_system;
tcsys.Database='TCFE7';
tcsys.Elements='Fe Cr v si n c mo mn ni';
tcsys.RejPhases='*';
tcsys.ResPhases='sigma m23 laves m6c fcc bcc liquid';
tcsys.Init;

%% Conditions

BaseEq=tcsys.GetInitialEquilibrium;
conds = 'T=1323 P=1e8 N=1 W(cr)=0.1542 w(mn)=0.00843 w(c)=0.00009 w(ni)=0.00559 w(mo)=0.00972 w(v)=0.00282 w(n)=0.005864 w(si)=0.00967';
BaseEq.SetConditions(conds);

%% Parameters for the minimizer, which is used as the solver. 

Eq=BaseEq.Clone;

parms = sk_solverParams(1); %Params object with 1 Variable
parms.x0 = [ Eq.GetValue('w(C)') ]; %start at current C-Content
parms.A = [ 1  ]; %w(c)*1<=0.5 Linear unequality
parms.b = 0.5;
parms.ub = [0.03 ]; %w(c) can be up to 0.03
parms.lb = [0]; %w(c) can be as less as 0

%% Initializsation of the minimizer
fun = sk_func_tc_properties(Eq, 'dg("fcc","bcc")');
varValues={'w(C)'};

solver = sk_solver_minimize_value;
solver.invert = true;
solver.varComponents=varValues;
solver.minFunc = fun;
solver.solvParm = parms;

%% Initialization of the mapper

mapper=sk_mapper;
mapper.Mode = 3; % Mode 3 = Step
mapper.zSolver = solver; % use the minizer as the result
mapper.Components = {'w(cr)'};
mapper.Ranges={...
    [0.05, 0.2, 3],...  %Variate w(cr) from 0.05 to 0.2 in 3 steps
    };

%% Start Mapping and get Result

mapper.doMapping;
mapper.Result

%% The Same using Properties

Eq.GetProperty('max("dg(""fcc"",""bcc"")","w(cr)","w(c)")')